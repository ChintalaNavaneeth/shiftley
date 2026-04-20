package onboarding

import (
	"fmt"
	"net/http"
	"path/filepath"
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

// OnboardEmployer handles POST /api/v1/onboarding/employer
// @Summary Onboard Employer
// @Description Completes the onboarding process for an employer
// @Tags Onboarding
// @Accept multipart/form-data
// @Produce json
// @Param full_name formData string true "Full Name"
// @Param business_name formData string true "Business Name"
// @Param business_logo formData file false "Business Logo"
// @Success 201 {object} utils.SuccessResponse
// @Failure 400 {object} utils.FailureResponse
// @Security ApiKeyAuth
// @Router /onboarding/employer [post]
func (h *Handler) OnboardEmployer(c *gin.Context) {
	fullName := c.PostForm("full_name")
	businessName := c.PostForm("business_name")

	if fullName == "" || businessName == "" {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Missing required fields", nil)
		return
	}

	var logoURL string
	file, err := c.FormFile("business_logo")
	if err == nil {
		extension := filepath.Ext(file.Filename)
		objectName := fmt.Sprintf("employers/%s/logo%s", uuid.New().String(), extension)

		f, err := file.Open()
		if err != nil {
			utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to open logo file", nil)
			return
		}
		defer f.Close()

		_, err = h.storage.UploadFile(c.Request.Context(), h.bucketLogos, objectName, f, file.Size, file.Header.Get("Content-Type"))
		if err != nil {
			utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to upload logo", nil)
			return
		}
		logoURL, _ = h.storage.GetFileURL(c.Request.Context(), h.bucketLogos, objectName)
	}

	utils.RespondSuccess(c, http.StatusCreated, gin.H{
		"message":      "Employer onboarding successful",
		"logo_url":     logoURL,
		"business_name": businessName,
	}, nil)
}

// OnboardEmployee handles POST /api/v1/onboarding/employee
// @Summary Onboard Employee
// @Description Completes the onboarding process for an employee
// @Tags Onboarding
// @Accept multipart/form-data
// @Produce json
// @Param full_name formData string true "Full Name"
// @Param profile_photo formData file false "Profile Photo"
// @Param aadhaar_front formData file true "Aadhaar Front"
// @Param aadhaar_back formData file true "Aadhaar Back"
// @Success 201 {object} utils.SuccessResponse
// @Failure 400 {object} utils.FailureResponse
// @Security ApiKeyAuth
// @Router /onboarding/employee [post]
func (h *Handler) OnboardEmployee(c *gin.Context) {
	fullName := c.PostForm("full_name")

	if fullName == "" {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Missing full name", nil)
		return
	}

	// In a real scenario, we'd loop through files or use a helper
	filesToUpload := []struct {
		fieldName string
		folder    string
	}{
		{"profile_photo", "profiles"},
		{"aadhaar_front", "kyc/aadhaar"},
		{"aadhaar_back", "kyc/aadhaar"},
	}

	uploadedUrls := make(map[string]string)
	for _, fInfo := range filesToUpload {
		file, err := c.FormFile(fInfo.fieldName)
		if err != nil {
			if fInfo.fieldName == "profile_photo" {
				continue // Profile photo is optional
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

		bucket := h.bucketProfiles
		if fInfo.folder == "kyc/aadhaar" {
			bucket = h.bucketKYC
		}

		objectName := fmt.Sprintf("%s/%s/%s%s", fInfo.folder, uuid.New().String(), fInfo.fieldName, filepath.Ext(file.Filename))
		_, err = h.storage.UploadFile(c.Request.Context(), bucket, objectName, f, file.Size, file.Header.Get("Content-Type"))
		if err != nil {
			utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, fmt.Sprintf("Failed to upload %s", fInfo.fieldName), nil)
			return
		}

		url, _ := h.storage.GetFileURL(c.Request.Context(), bucket, objectName)
		uploadedUrls[fInfo.fieldName] = url
	}

	utils.RespondSuccess(c, http.StatusCreated, gin.H{
		"message":       "Employee onboarding successful",
		"uploaded_urls": uploadedUrls,
		"full_name":     fullName,
	}, nil)
}
