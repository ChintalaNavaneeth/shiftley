package onboarding

import (
	"encoding/json"
	"fmt"
	"net/http"
	"path/filepath"
	"strconv"
	"time"
	"shiftley/internal/auth"
	"shiftley/internal/verifier"
	"shiftley/pkg/notify"
	"shiftley/pkg/storage"
	"shiftley/pkg/utils"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

// OnboardEmployerRequest represents the multipart/form-data for employer onboarding.
type OnboardEmployerRequest struct {
	FullName            string `form:"full_name" binding:"required"`
	Email               string `form:"email" binding:"required"`
	BusinessName        string `form:"business_name" binding:"required"`
	BusinessType        string `form:"business_type" binding:"required"`
	Location            string `form:"location" binding:"required" example:"{\"lat\":12.9716,\"lng\":77.5946}"`
	BusinessAddress     string `form:"business_address" binding:"required"`
	GSTNumber           string `form:"gst_number"`
	BusinessPhone       string `form:"business_phone_number" binding:"required"`
	EmployerPhone       string `form:"employer_phone_number" binding:"required"`
	AadhaarNumber       string `form:"aadhaar_number" binding:"required"`
}

// OnboardEmployeeRequest represents the multipart/form-data for employee onboarding.
type OnboardEmployeeRequest struct {
	FullName       string `form:"full_name" binding:"required"`
	Email          string `form:"email" binding:"required"`
	PhoneNumber    string `form:"phone_number" binding:"required"`
	SkillIDs       string `form:"skill_ids" binding:"required" example:"[\"uuid-1\",\"uuid-2\"]"`
	Degree         string `form:"degree"`
	Specialization string `form:"specialization"`
	PassingYear    string `form:"passing_year"`
}

type Handler struct {
	db             *gorm.DB
	storage        storage.Storage
	bucketProfiles string
	bucketLogos    string
	bucketKYC      string
	notify         *notify.NotifyService
	authSvc        auth.Service
}

func NewHandler(db *gorm.DB, storage storage.Storage, bucketProfiles, bucketLogos, bucketKYC string, notifySvc *notify.NotifyService, authSvc auth.Service) *Handler {
	return &Handler{
		db:             db,
		storage:        storage,
		bucketProfiles: bucketProfiles,
		bucketLogos:    bucketLogos,
		bucketKYC:      bucketKYC,
		notify:         notifySvc,
		authSvc:        authSvc,
	}
}

type Location struct {
	Lat float64 `json:"lat"`
	Lng float64 `json:"lng"`
}

// OnboardEmployer handles POST /api/v1/onboarding/employer
// @Summary Onboard Employer
// @Description Submits employer registration details and documents. Requires a registration token. Uses multipart/form-data.
// @Tags Onboarding
// @Accept multipart/form-data
// @Produce json
// @Param full_name formData string true "Full Name"
// @Param email formData string true "Email"
// @Param business_name formData string true "Business Name"
// @Param business_type formData string true "Business Type"
// @Param location formData string true "Location as JSON: {\"lat\":12.97,\"lng\":77.59}"
// @Param business_address formData string true "Business Address"
// @Param gst_number formData string false "GST Number"
// @Param business_phone_number formData string true "Business Phone Number"
// @Param employer_phone_number formData string true "Employer Phone Number"
// @Param aadhaar_number formData string true "Aadhaar Number"
// @Param aadhaar_pdf formData file true "Aadhaar PDF"
// @Param business_photo_1 formData file true "Business Photo 1"
// @Param business_photo_2 formData file true "Business Photo 2"
// @Param business_photo_3 formData file true "Business Photo 3"
// @Success 201 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /onboarding/employer [post]
func (h *Handler) OnboardEmployer(c *gin.Context) {
	userIDStr, _ := c.Get("userID")
	userID, err := uuid.Parse(userIDStr.(string))
	if err != nil {
		utils.RespondError(c, http.StatusUnauthorized, utils.ErrUnauthorized, "Invalid user session", nil)
		return
	}

	// 1. Extract Text Fields
	fullName := c.PostForm("full_name")
	businessName := c.PostForm("business_name")
	businessType := c.PostForm("business_type")
	locationStr := c.PostForm("location")
	businessAddress := c.PostForm("business_address")
	gstNumber := c.PostForm("gst_number")
	email := c.PostForm("email")
	businessPhone := c.PostForm("business_phone_number")
	employerPhone := c.PostForm("employer_phone_number")
	aadhaarNumber := c.PostForm("aadhaar_number")

	// 2. Validate Required Fields
	if fullName == "" || businessName == "" || businessType == "" || locationStr == "" ||
		businessAddress == "" || email == "" || businessPhone == "" || employerPhone == "" || aadhaarNumber == "" {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Missing required text fields", nil)
		return
	}

	// 3. Parse Location
	var loc Location
	if err := json.Unmarshal([]byte(locationStr), &loc); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid location format", nil)
		return
	}

	// 4. Handle File Uploads
	filesToUpload := []struct {
		fieldName string
		bucket    string
		optional  bool
	}{
		{"aadhaar_pdf", h.bucketKYC, false},
		{"business_photo_1", h.bucketLogos, false},
		{"business_photo_2", h.bucketLogos, false},
		{"business_photo_3", h.bucketLogos, false},
	}

	uploadedUrls := make(map[string]string)
	for _, fInfo := range filesToUpload {
		file, err := c.FormFile(fInfo.fieldName)
		if err != nil {
			if fInfo.optional {
				continue
			}
			utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, fmt.Sprintf("%s is required", fInfo.fieldName), nil)
			return
		}

		f, _ := file.Open()
		defer f.Close()

		extension := filepath.Ext(file.Filename)
		objectName := fmt.Sprintf("employers/%s/%s%s", userID, fInfo.fieldName, extension)

		_, err = h.storage.UploadFile(c.Request.Context(), fInfo.bucket, objectName, f, file.Size, file.Header.Get("Content-Type"))
		if err != nil {
			utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Upload failed", nil)
			return
		}

		url, _ := h.storage.GetFileURL(c.Request.Context(), fInfo.bucket, objectName)
		uploadedUrls[fInfo.fieldName] = url
	}

	// 5. Persist to Database
	tx := h.db.Begin()

	// Update User FullName and Email
	if err := tx.Model(&auth.User{}).Where("id = ?", userID).Updates(map[string]interface{}{
		"full_name":   fullName,
		"email":       email,
		"is_verified": false, // Stays unverified until physical check
		"is_initial_setup_complete": true,
	}).Error; err != nil {
		tx.Rollback()
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to update user", nil)
		return
	}

	employerProfile := auth.EmployerProfile{
		UserID:          userID,
		BusinessName:    businessName,
		BusinessType:    businessType,
		GSTNumber:       gstNumber,
		BusinessAddress: businessAddress,
		Lat:             loc.Lat,
		Lng:             loc.Lng,
		Location:        fmt.Sprintf("POINT(%f %f)", loc.Lng, loc.Lat),
		AadhaarLast4:    aadhaarNumber[len(aadhaarNumber)-4:],
		AadhaarURL:      uploadedUrls["aadhaar_pdf"],
		PhotoURLs: []string{
			uploadedUrls["business_photo_1"],
			uploadedUrls["business_photo_2"],
			uploadedUrls["business_photo_3"],
		},
	}

	if err := tx.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "user_id"}},
		UpdateAll: true,
	}).Create(&employerProfile).Error; err != nil {
		tx.Rollback()
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to save employer profile", nil)
		return
	}

	// 6. Create KYC Session for Verifier Queue
	kycSession := auth.KYCSession{
		UserID:        userID,
		Provider:      "PHYSICAL_VISIT",
		Status:        "PENDING",
		MaskedAadhaar: employerProfile.AadhaarLast4,
	}
	if err := tx.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "user_id"}},
		UpdateAll: true,
	}).Create(&kycSession).Error; err != nil {
		tx.Rollback()
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to create KYC session", nil)
		return
	}

	tx.Commit()

	h.notify.SendEmployerVerificationPending(employerPhone, fullName, businessName)

	// Generate Session Tokens
	accessToken, err := h.authSvc.GenerateToken(userID, "EMPLOYER", "session", 24)
	if err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to generate access token", nil)
		return
	}
	refreshToken, err := h.authSvc.GenerateToken(userID, "EMPLOYER", "refresh", 24*7)
	if err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to generate refresh token", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusCreated, gin.H{
		"profile":       employerProfile,
		"access_token":  accessToken,
		"refresh_token": refreshToken,
	}, nil)
}

// OnboardEmployee handles POST /api/v1/onboarding/employee
// @Summary Onboard Employee (Worker)
// @Description Submits worker registration details, profile picture, and Aadhaar document. Requires a registration token. Uses multipart/form-data.
// @Tags Onboarding
// @Accept multipart/form-data
// @Produce json
// @Param full_name formData string true "Full Name"
// @Param email formData string true "Email"
// @Param phone_number formData string true "Phone Number"
// @Param skill_ids formData string true "Skill UUIDs as JSON array: [\"uuid-1\",\"uuid-2\"]"
// @Param degree formData string false "Degree (Optional)"
// @Param specialization formData string false "Specialization (Optional)"
// @Param passing_year formData string false "Passing Year (Optional)"
// @Param location formData string true "Location as JSON: {\"lat\":12.97,\"lng\":77.59}"
// @Param profile_picture formData file true "Profile Picture"
// @Param aadhaar_pdf formData file true "Aadhaar PDF"
// @Success 201 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /onboarding/employee [post]
func (h *Handler) OnboardEmployee(c *gin.Context) {
	userIDStr, _ := c.Get("userID")
	userID, err := uuid.Parse(userIDStr.(string))
	if err != nil {
		utils.RespondError(c, http.StatusUnauthorized, utils.ErrUnauthorized, "Invalid user session", nil)
		return
	}

	// 1. Extract Text Fields
	fullName := c.PostForm("full_name")
	email := c.PostForm("email")
	phoneNumber := c.PostForm("phone_number")
	skillIdsStr := c.PostForm("skill_ids")
	degree := c.PostForm("degree")
	specialization := c.PostForm("specialization")
	passingYearStr := c.PostForm("passing_year")
	locationStr := c.PostForm("location")

	// 2. Validate Required Fields
	if fullName == "" || email == "" || phoneNumber == "" || skillIdsStr == "" || locationStr == "" {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Missing required text fields", nil)
		return
	}

	// 3. Parse Skill IDs (UUIDs)
	var skillIds []string
	if err := json.Unmarshal([]byte(skillIdsStr), &skillIds); err != nil || len(skillIds) == 0 {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "skill_ids must be a valid JSON array of UUIDs", nil)
		return
	}

	// 4. Parse Passing Year (Optional)
	var passingYear int
	if passingYearStr != "" {
		passingYear, _ = strconv.Atoi(passingYearStr)
	}

	// 5. Parse Location
	var loc Location
	if err := json.Unmarshal([]byte(locationStr), &loc); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid location format", nil)
		return
	}

	// 6. Handle File Uploads
	filesToUpload := []struct {
		fieldName string
		bucket    string
		optional  bool
	}{
		{"aadhaar_pdf", h.bucketKYC, false},
		{"profile_picture", h.bucketProfiles, false},
	}

	uploadedUrls := make(map[string]string)
	for _, fInfo := range filesToUpload {
		file, err := c.FormFile(fInfo.fieldName)
		if err != nil {
			if fInfo.optional {
				continue
			}
			utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, fmt.Sprintf("%s is required", fInfo.fieldName), nil)
			return
		}

		f, _ := file.Open()
		defer f.Close()

		extension := filepath.Ext(file.Filename)
		objectName := fmt.Sprintf("employees/%s/%s%s", userID, fInfo.fieldName, extension)

		_, err = h.storage.UploadFile(c.Request.Context(), fInfo.bucket, objectName, f, file.Size, file.Header.Get("Content-Type"))
		if err != nil {
			utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Upload failed", nil)
			return
		}

		url, _ := h.storage.GetFileURL(c.Request.Context(), fInfo.bucket, objectName)
		uploadedUrls[fInfo.fieldName] = url
	}

	// 6. Persist to Database
	tx := h.db.Begin()

	if err := tx.Model(&auth.User{}).Where("id = ?", userID).Updates(map[string]interface{}{
		"full_name":         fullName,
		"email":             email,
		"profile_photo_url": uploadedUrls["profile_picture"],
		"is_verified":       true,
		"is_initial_setup_complete": true,
	}).Error; err != nil {
		tx.Rollback()
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to update user", nil)
		return
	}

	workerProfile := auth.WorkerProfile{
		UserID:          userID,
		Lat:             loc.Lat,
		Lng:             loc.Lng,
		Location:        fmt.Sprintf("POINT(%f %f)", loc.Lng, loc.Lat),
		ProfilePhotoURL: uploadedUrls["profile_picture"],
		Degree:          degree,
		Specialization:  specialization,
		PassingYear:     passingYear,
		Skills:          skillIds,
	}

	if err := tx.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "user_id"}},
		UpdateAll: true,
	}).Create(&workerProfile).Error; err != nil {
		tx.Rollback()
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to save worker profile", nil)
		return
	}

	// 7. Create Auto-Verified KYC Session for Employee
	now := time.Now()
	kycSession := auth.KYCSession{
		UserID:     userID,
		Provider:   "AUTO_VERIFY",
		Status:     "VERIFIED",
		VerifiedAt: &now,
	}
	if err := tx.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "user_id"}},
		UpdateAll: true,
	}).Create(&kycSession).Error; err != nil {
		tx.Rollback()
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to create KYC session", nil)
		return
	}

	tx.Commit()

	// Generate Session Tokens
	accessToken, err := h.authSvc.GenerateToken(userID, "WORKER", "session", 24)
	if err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to generate access token", nil)
		return
	}
	refreshToken, err := h.authSvc.GenerateToken(userID, "WORKER", "refresh", 24*7)
	if err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to generate refresh token", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusCreated, gin.H{
		"profile":       workerProfile,
		"access_token":  accessToken,
		"refresh_token": refreshToken,
	}, nil)
}

// OnboardVerifier handles POST /api/v1/onboarding/verifier
func (h *Handler) OnboardVerifier(c *gin.Context) {
	userIDStr, _ := c.Get("userID")
	userID, err := uuid.Parse(userIDStr.(string))
	if err != nil {
		utils.RespondError(c, http.StatusUnauthorized, utils.ErrUnauthorized, "Invalid user session", nil)
		return
	}

	// 1. Extract Lat/Lng
	latStr := c.PostForm("latitude")
	lngStr := c.PostForm("longitude")

	lat, _ := strconv.ParseFloat(latStr, 64)
	lng, _ := strconv.ParseFloat(lngStr, 64)

	if lat == 0 || lng == 0 {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Latitude and Longitude are required", nil)
		return
	}

	// 2. Handle File Uploads
	filesToUpload := []struct {
		fieldName string
		bucket    string
	}{
		{"profile_image", h.bucketProfiles},
		{"aadhar_pdf", h.bucketKYC},
	}

	uploadedUrls := make(map[string]string)
	for _, fInfo := range filesToUpload {
		file, err := c.FormFile(fInfo.fieldName)
		if err != nil {
			utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, fmt.Sprintf("%s is required", fInfo.fieldName), nil)
			return
		}

		f, _ := file.Open()
		defer f.Close()

		extension := filepath.Ext(file.Filename)
		objectName := fmt.Sprintf("verifiers/%s/%s%s", userID, fInfo.fieldName, extension)

		_, err = h.storage.UploadFile(c.Request.Context(), fInfo.bucket, objectName, f, file.Size, file.Header.Get("Content-Type"))
		if err != nil {
			utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Upload failed", nil)
			return
		}

		url, _ := h.storage.GetFileURL(c.Request.Context(), fInfo.bucket, objectName)
		uploadedUrls[fInfo.fieldName] = url
	}

	// 3. Persist to Database
	tx := h.db.Begin()

	if err := tx.Model(&auth.User{}).Where("id = ?", userID).Updates(map[string]interface{}{
		"is_initial_setup_complete": true,
		"is_verified":               true,
		"profile_photo_url":         uploadedUrls["profile_image"],
	}).Error; err != nil {
		tx.Rollback()
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to update user", nil)
		return
	}

	verifierProfile := verifier.VerifierProfile{
		UserID:          userID,
		ProfilePhotoURL: uploadedUrls["profile_image"],
		AadhaarURL:      uploadedUrls["aadhar_pdf"],
		Lat:             lat,
		Lng:             lng,
		Location:        fmt.Sprintf("POINT(%f %f)", lng, lat),
	}

	if err := tx.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "user_id"}},
		UpdateAll: true,
	}).Create(&verifierProfile).Error; err != nil {
		tx.Rollback()
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to save verifier profile", nil)
		return
	}

	tx.Commit()

	// Generate Session Tokens
	accessToken, err := h.authSvc.GenerateToken(userID, "VERIFIER", "session", 24)
	if err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to generate access token", nil)
		return
	}
	refreshToken, err := h.authSvc.GenerateToken(userID, "VERIFIER", "refresh", 24*7)
	if err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to generate refresh token", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusCreated, gin.H{
		"profile":       verifierProfile,
		"access_token":  accessToken,
		"refresh_token": refreshToken,
	}, nil)
}
