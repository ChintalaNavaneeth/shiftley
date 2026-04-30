package onboarding

import (
	"encoding/json"
	"fmt"
	"net/http"
	"path/filepath"
	"strconv"
	"shiftley/pkg/notify"
	"shiftley/pkg/storage"
	"shiftley/pkg/utils"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type Handler struct {
	db             *gorm.DB
	storage        storage.Storage
	bucketProfiles string
	bucketLogos    string
	bucketKYC      string
	notify         *notify.NotifyService
}

func NewHandler(db *gorm.DB, storage storage.Storage, bucketProfiles, bucketLogos, bucketKYC string, notifySvc *notify.NotifyService) *Handler {
	return &Handler{
		db:             db,
		storage:        storage,
		bucketProfiles: bucketProfiles,
		bucketLogos:    bucketLogos,
		bucketKYC:      bucketKYC,
		notify:         notifySvc,
	}
}

type Location struct {
	Lat float64 `json:"lat"`
	Lng float64 `json:"lng"`
}

// OnboardEmployer handles POST /api/v1/onboarding/employer
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
		AadhaarLast4:    aadhaarNumber[len(aadhaarNumber)-4:],
		AadhaarURL:      uploadedUrls["aadhaar_pdf"],
		PhotoURLs: []string{
			uploadedUrls["business_photo_1"],
			uploadedUrls["business_photo_2"],
			uploadedUrls["business_photo_3"],
		},
	}

	if err := tx.Create(&employerProfile).Error; err != nil {
		tx.Rollback()
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to create employer profile", nil)
		return
	}

	tx.Commit()

	h.notify.SendEmployerVerificationPending(employerPhone, fullName, businessName)

	utils.RespondSuccess(c, http.StatusCreated, employerProfile, nil)
}

// OnboardEmployee handles POST /api/v1/onboarding/employee
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

	// 2. Validate Required Fields
	if fullName == "" || email == "" || phoneNumber == "" || skillIdsStr == "" {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Missing required text fields", nil)
		return
	}

	// 3. Parse Skill IDs
	var skillIds []string
	json.Unmarshal([]byte(skillIdsStr), &skillIds)

	// 4. Parse Passing Year (Optional)
	var passingYear int
	if passingYearStr != "" {
		passingYear, _ = strconv.Atoi(passingYearStr)
	}

	// 5. Handle File Uploads
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
		"full_name":   fullName,
		"email":       email,
		"is_verified": true, // Employee auto-verified for MVP (or should it be false?)
	}).Error; err != nil {
		tx.Rollback()
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to update user", nil)
		return
	}

	workerProfile := auth.WorkerProfile{
		UserID:          userID,
		ProfilePhotoURL: uploadedUrls["profile_picture"],
		Degree:          degree,
		Specialization:  specialization,
		PassingYear:     passingYear,
		Skills:          skillIds,
	}

	if err := tx.Create(&workerProfile).Error; err != nil {
		tx.Rollback()
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to create worker profile", nil)
		return
	}

	tx.Commit()

	utils.RespondSuccess(c, http.StatusCreated, workerProfile, nil)
}
