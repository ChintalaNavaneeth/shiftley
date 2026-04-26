package auth

import (
	"net/http"
	"shiftley/pkg/notify"
	"shiftley/pkg/utils"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Handler struct {
	svc    Service
	notify *notify.NotifyService
	db     *gorm.DB
}

func NewHandler(svc Service, notifySvc *notify.NotifyService, db *gorm.DB) *Handler {
	return &Handler{svc: svc, notify: notifySvc, db: db}
}

type SendOTPRequest struct {
	Identifier string `json:"identifier" form:"identifier" binding:"required"`
	Type       string `json:"type" form:"type" binding:"required,oneof=PHONE EMAIL"`
	Role       string `json:"role" form:"role" binding:"required,oneof=WORKER EMPLOYER"`
}

// SendOTP handles POST /api/v1/auth/otp/send
// @Summary Request OTP
// @Description Sends a 6-digit OTP to the user's phone or email
// @Tags Auth
// @Accept x-www-form-urlencoded
// @Produce json
// @Param identifier formData string true "Identifier (Phone or Email)"
// @Param type formData string true "Type" Enums(PHONE, EMAIL)
// @Param role formData string true "Role" Enums(WORKER, EMPLOYER)
// @Success 200 {object} utils.SuccessResponse
// @Failure 400 {object} utils.FailureResponse
// @Failure 500 {object} utils.FailureResponse
// @Router /auth/otp/send [post]
func (h *Handler) SendOTP(c *gin.Context) {
	var req SendOTPRequest
	if err := c.ShouldBind(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", []string{err.Error()})
		return
	}

	code, err := h.svc.SendOTP(c.Request.Context(), req.Identifier, req.Type, req.Role)
	if err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to send OTP", []string{err.Error()})
		return
	}

	// Fire WhatsApp OTP notification (non-blocking)
	h.notify.SendOTP(req.Identifier, code)

	utils.RespondSuccess(c, http.StatusOK, "OTP sent successfully", nil)
}

type VerifyOTPRequest struct {
	Identifier string `json:"identifier" form:"identifier" binding:"required"`
	Type       string `json:"type" form:"type" binding:"required,oneof=PHONE EMAIL"`
	Code       string `json:"code" form:"code" binding:"required,len=6"`
}

// VerifyOTP handles POST /api/v1/auth/otp/verify
// @Summary Verify OTP
// @Description Verifies the OTP and returns a JWT token
// @Tags Auth
// @Accept x-www-form-urlencoded
// @Produce json
// @Param identifier formData string true "Identifier (Phone or Email)"
// @Param type formData string true "Type" Enums(PHONE, EMAIL)
// @Param code formData string true "6-digit OTP"
// @Success 200 {object} utils.SuccessResponse
// @Failure 400 {object} utils.FailureResponse
// @Router /auth/otp/verify [post]
func (h *Handler) VerifyOTP(c *gin.Context) {
	var req VerifyOTPRequest
	if err := c.ShouldBind(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", []string{err.Error()})
		return
	}

	token, isNewUser, user, err := h.svc.VerifyOTP(c.Request.Context(), req.Identifier, req.Type, req.Code)
	if err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, err.Error(), nil)
		return
	}

	if isNewUser {
		utils.RespondSuccess(c, http.StatusOK, gin.H{
			"is_new_user":        true,
			"registration_token": token,
		}, nil)
	} else {
		utils.RespondSuccess(c, http.StatusOK, gin.H{
			"is_new_user":   false,
			"session_token": token,
			"user": gin.H{
				"id":         user.ID,
				"role":       user.Role,
				"is_verified": user.IsVerified,
			},
		}, nil)
	}
}

// VerifyAadhaarXML handles POST /api/v1/auth/kyc/aadhaar-xml
func (h *Handler) VerifyAadhaarXML(c *gin.Context) {
	userIDStr, _ := c.Get("userID")
	userID, _ := uuid.Parse(userIDStr.(string))

	shareCode := c.PostForm("share_code")
	file, err := c.FormFile("xml_file")
	if err != nil || shareCode == "" {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "XML file and share code are required", nil)
		return
	}

	// 1. Process File (Simplified: assuming extracted XML or standard Zip)
	// In production, use github.com/alexmullins/zip for password-protected zips
	f, _ := file.Open()
	defer f.Close()

	// Mock data extraction (simulate XML parsing)
	// Normal flow: Read XML -> Decrypt with share code -> Verify UIDAI Signature -> Extract
	fmt.Printf("[MOCK Aadhaar KYC] Verifying XML for user %s with share code %s\n", userID, shareCode)

	// Simulation of extracted data
	extractedName := "Verified User"
	maskedAadhaar := "XXXX XXXX 1234"

	// 2. Update KYC Session
	now := time.Now()
	kyc := &KYCSession{
		UserID:        userID,
		Provider:      "OFFLINE_XML",
		Status:        "VERIFIED",
		MaskedAadhaar: maskedAadhaar,
		VerifiedAt:    &now,
	}

	if err := h.db.Where("user_id = ?", userID).Assign(kyc).FirstOrCreate(&kyc).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to save KYC results", nil)
		return
	}

	// 3. Update User Status
	if err := h.db.Model(&User{}).Where("id = ?", userID).Updates(map[string]interface{}{
		"is_verified": true,
		"full_name":   extractedName,
	}).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to update user status", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"name":           extractedName,
		"masked_aadhaar": maskedAadhaar,
		"status":         "VERIFIED",
	}, nil)
}

