package verifier

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
	repo      Repository
	storage   storage.Storage
	bucketKYC string
}

func NewHandler(repo Repository, storage storage.Storage, bucketKYC string) *Handler {
	return &Handler{
		repo:      repo,
		storage:   storage,
		bucketKYC: bucketKYC,
	}
}

// GetQueue handles GET /api/v1/verifier/queue
// @Summary Get Pending Queues
// @Description Fetches a list of users awaiting verification.
// @Tags Verifier
// @Produce json
// @Param type query string false "User Type (EMPLOYER or EMPLOYEE)"
// @Param limit query int false "Limit"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /verifier/queue [get]
func (h *Handler) GetQueue(c *gin.Context) {
	userType := c.Query("type")
	limitStr := c.DefaultQuery("limit", "20")
	limit, _ := strconv.Atoi(limitStr)

	items, err := h.repo.GetPendingQueue(c.Request.Context(), userType, limit)
	if err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to fetch queue", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, items, nil)
}

// VerifyEmployer handles POST /api/v1/verifier/employers/:id/verify
// @Summary Verify Employer (Physical Visit)
// @Description Finalizes the physical location check with photographic proof.
// @Tags Verifier
// @Accept multipart/form-data
// @Produce json
// @Param id path string true "User ID"
// @Param status formData string true "APPROVED or REJECTED"
// @Param notes formData string false "Verification Notes"
// @Param verified_location formData string false "JSON GPS pin override"
// @Param verifier_selfie formData file true "Selfie of verifier at location"
// @Param location_photo_1 formData file true "Location Proof 1"
// @Param location_photo_2 formData file true "Location Proof 2"
// @Param location_photo_3 formData file true "Location Proof 3"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /verifier/employers/{id}/verify [post]
func (h *Handler) VerifyEmployer(c *gin.Context) {
	userID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid user ID", nil)
		return
	}

	verifierIDStr, _ := c.Get("userID")
	verifierID, _ := uuid.Parse(verifierIDStr.(string))

	status := c.PostForm("status")
	notes := c.PostForm("notes")
	locationStr := c.PostForm("verified_location")

	if status != "APPROVED" && status != "REJECTED" {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Status must be APPROVED or REJECTED", nil)
		return
	}

	var lat, lng float64
	if locationStr != "" {
		var loc struct {
			Lat float64 `json:"lat"`
			Lng float64 `json:"lng"`
		}
		if err := json.Unmarshal([]byte(locationStr), &loc); err == nil {
			lat, lng = loc.Lat, loc.Lng
		}
	}

	// Handle File Uploads
	fields := []string{"verifier_selfie", "location_photo_1", "location_photo_2", "location_photo_3"}
	urls := make(map[string]string)

	for _, field := range fields {
		fileHeader, err := c.FormFile(field)
		if err != nil {
			if status == "APPROVED" {
				utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, fmt.Sprintf("Missing required file: %s", field), nil)
				return
			}
			continue // Optional for rejection
		}

		file, err := fileHeader.Open()
		if err != nil {
			utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, fmt.Sprintf("Failed to open %s", field), nil)
			return
		}
		defer file.Close()

		extension := filepath.Ext(fileHeader.Filename)
		objectName := fmt.Sprintf("verifications/%s/%s%s", userID, field, extension)

		_, err = h.storage.UploadFile(c.Request.Context(), h.bucketKYC, objectName, file, fileHeader.Size, fileHeader.Header.Get("Content-Type"))
		if err != nil {
			utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, fmt.Sprintf("Failed to upload %s", field), nil)
			return
		}

		url, _ := h.storage.GetFileURL(c.Request.Context(), h.bucketKYC, objectName)
		urls[field] = url
	}

	audit := &VerificationAudit{
		UserID:            userID,
		VerifierID:        verifierID,
		Status:            status,
		Notes:             notes,
		VerifierSelfieURL: urls["verifier_selfie"],
		LocationPhoto1URL: urls["location_photo_1"],
		LocationPhoto2URL: urls["location_photo_2"],
		LocationPhoto3URL: urls["location_photo_3"],
		VerifiedLat:       lat,
		VerifiedLng:       lng,
	}

	kycStatus := "VERIFIED"
	if status == "REJECTED" {
		kycStatus = "REJECTED"
	}

	if err := h.repo.SubmitVerification(c.Request.Context(), audit, kycStatus); err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to submit verification", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, gin.H{"status": kycStatus}, nil)
}

// VerifyEmployee handles POST /api/v1/verifier/employees/:id/verify
// @Summary Verify Employee (Remote KYC)
// @Description Remotely approve an employee after reviewing Aadhaar and photo.
// @Tags Verifier
// @Accept json
// @Produce json
// @Param id path string true "User ID"
// @Param request body object true "Status and Notes"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /verifier/employees/{id}/verify [post]
func (h *Handler) VerifyEmployee(c *gin.Context) {
	userID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid user ID", nil)
		return
	}

	verifierIDStr, _ := c.Get("userID")
	verifierID, _ := uuid.Parse(verifierIDStr.(string))

	var req struct {
		Status string `json:"status" binding:"required"`
		Notes  string `json:"notes"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request body", nil)
		return
	}

	kycStatus := "VERIFIED"
	if req.Status == "REJECTED" {
		kycStatus = "REJECTED"
	}

	audit := &VerificationAudit{
		UserID:     userID,
		VerifierID: verifierID,
		Status:     req.Status,
		Notes:      req.Notes,
	}

	if err := h.repo.SubmitVerification(c.Request.Context(), audit, kycStatus); err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to submit verification", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, gin.H{"status": kycStatus}, nil)
}
