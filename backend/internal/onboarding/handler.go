package onboarding

import (
	"encoding/json"
	"fmt"
	"net/http"
	"path/filepath"
	"strconv"
	"shiftley/pkg/storage"
	"shiftley/pkg/utils"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type Handler struct {
	storage        storage.Storage
	bucketProfiles string
	bucketLogos    string
	bucketKYC      string
}

func NewHandler(storage storage.Storage, bucketProfiles, bucketLogos, bucketKYC string) *Handler {
	return &Handler{
		storage:        storage,
		bucketProfiles: bucketProfiles,
		bucketLogos:    bucketLogos,
		bucketKYC:      bucketKYC,
	}
}

type Location struct {
	Lat float64 `json:"lat"`
	Lng float64 `json:"lng"`
}

// OnboardEmployer handles POST /api/v1/onboarding/employer
// @Summary Onboard Employer
// @Description Completes the onboarding process for an employer
// @Tags Onboarding
// @Accept multipart/form-data
// @Produce json
// @Param full_name formData string true "Full Name"
// @Param business_name formData string true "Business Name"
// @Param business_type formData string true "Business Type"
// @Param location formData string true "Location (JSON string: {\"lat\": 17.68, \"lng\": 83.21})"
// @Param business_address formData string true "Business Address"
// @Param gst_number formData string false "GST Number (Optional)"
// @Param email formData string true "Email"
// @Param business_phone_number formData string true "Business Phone Number"
// @Param employer_phone_number formData string true "Employer Phone Number"
// @Param aadhaar_number formData string true "Aadhaar Number (12 digits)"
// @Param aadhaar_pdf formData file true "Aadhaar PDF (Masked)"
// @Param business_photo_1 formData file true "Business Photo 1"
// @Param business_photo_2 formData file true "Business Photo 2"
// @Param business_photo_3 formData file true "Business Photo 3"
// @Success 201 {object} utils.SuccessResponse
// @Failure 400 {object} utils.FailureResponse
// @Security ApiKeyAuth
// @Router /onboarding/employer [post]
func (h *Handler) OnboardEmployer(c *gin.Context) {
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
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid location format. Expected JSON: {\"lat\": 0, \"lng\": 0}", nil)
		return
	}

	// 4. Validate Aadhaar
	if len(aadhaarNumber) != 12 {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Aadhaar number must be exactly 12 digits", nil)
		return
	}
	maskedAadhaar := "XXXXXXXX" + aadhaarNumber[8:]

	// 5. Handle File Uploads
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

		f, err := file.Open()
		if err != nil {
			utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, fmt.Sprintf("Failed to open %s", fInfo.fieldName), nil)
			return
		}
		defer f.Close()

		extension := filepath.Ext(file.Filename)
		objectName := fmt.Sprintf("employers/%s/%s%s", uuid.New().String(), fInfo.fieldName, extension)

		_, err = h.storage.UploadFile(c.Request.Context(), fInfo.bucket, objectName, f, file.Size, file.Header.Get("Content-Type"))
		if err != nil {
			utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, fmt.Sprintf("Failed to upload %s", fInfo.fieldName), nil)
			return
		}

		url, _ := h.storage.GetFileURL(c.Request.Context(), fInfo.bucket, objectName)
		uploadedUrls[fInfo.fieldName] = url
	}

	// 6. Return Success with aggregated data
	utils.RespondSuccess(c, http.StatusCreated, gin.H{
		"message":               "Employer onboarding successful",
		"full_name":             fullName,
		"business_name":         businessName,
		"business_type":         businessType,
		"location":              loc,
		"business_address":      businessAddress,
		"gst_number":            gstNumber,
		"email":                 email,
		"business_phone_number": businessPhone,
		"employer_phone_number": employerPhone,
		"masked_aadhaar":        maskedAadhaar,
		"uploaded_urls":         uploadedUrls,
	}, nil)
}

// OnboardEmployee handles POST /api/v1/onboarding/employee
// @Summary Onboard Employee
// @Description Completes the onboarding process for an employee
// @Tags Onboarding
// @Accept multipart/form-data
// @Produce json
// @Param full_name formData string true "Full Name"
// @Param email formData string true "Email"
// @Param phone_number formData string true "Phone Number"
// @Param skill_ids formData string true "Skill IDs (JSON array: [\"nano_waiter\", \"nano_delivery\"])"
// @Param degree formData string false "Degree (Optional)"
// @Param specialization formData string false "Specialization (Optional)"
// @Param passing_year formData integer false "Passing Year (Optional)"
// @Param aadhaar_pdf formData file true "Aadhaar PDF (Masked)"
// @Param profile_picture formData file true "Profile Picture (Professional)"
// @Success 201 {object} utils.SuccessResponse
// @Failure 400 {object} utils.FailureResponse
// @Security ApiKeyAuth
// @Router /onboarding/employee [post]
func (h *Handler) OnboardEmployee(c *gin.Context) {
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
	if err := json.Unmarshal([]byte(skillIdsStr), &skillIds); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid skill_ids format. Expected JSON array of strings", nil)
		return
	}

	// 4. Parse Passing Year (Optional)
	var passingYear int
	var err error
	if passingYearStr != "" {
		passingYear, err = strconv.Atoi(passingYearStr)
		if err != nil {
			utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid passing_year. Expected an integer", nil)
			return
		}
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

		f, err := file.Open()
		if err != nil {
			utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, fmt.Sprintf("Failed to open %s", fInfo.fieldName), nil)
			return
		}
		defer f.Close()

		extension := filepath.Ext(file.Filename)
		objectName := fmt.Sprintf("employees/%s/%s%s", uuid.New().String(), fInfo.fieldName, extension)

		_, err = h.storage.UploadFile(c.Request.Context(), fInfo.bucket, objectName, f, file.Size, file.Header.Get("Content-Type"))
		if err != nil {
			utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, fmt.Sprintf("Failed to upload %s", fInfo.fieldName), nil)
			return
		}

		url, _ := h.storage.GetFileURL(c.Request.Context(), fInfo.bucket, objectName)
		uploadedUrls[fInfo.fieldName] = url
	}

	// 6. Return Success with aggregated data
	utils.RespondSuccess(c, http.StatusCreated, gin.H{
		"message":        "Employee onboarding successful",
		"full_name":      fullName,
		"email":          email,
		"phone_number":   phoneNumber,
		"skill_ids":      skillIds,
		"degree":         degree,
		"specialization": specialization,
		"passing_year":   passingYear,
		"uploaded_urls":  uploadedUrls,
	}, nil)
}
