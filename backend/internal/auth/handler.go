package auth

import (
	"net/http"
	"shiftley/pkg/utils"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	svc Service
}

func NewHandler(svc Service) *Handler {
	return &Handler{svc: svc}
}

type SendOTPRequest struct {
	Identifier string `json:"identifier" binding:"required"`
	Type       string `json:"type" binding:"required,oneof=PHONE EMAIL"`
	Role       string `json:"role" binding:"required,oneof=WORKER EMPLOYER"`
}

// SendOTP handles POST /api/v1/auth/otp/send
// @Summary Request OTP
// @Description Sends a 6-digit OTP to the user's phone or email
// @Tags Auth
// @Accept json
// @Produce json
// @Param request body SendOTPRequest true "OTP Request"
// @Success 200 {object} utils.SuccessResponse
// @Failure 400 {object} utils.FailureResponse
// @Failure 500 {object} utils.FailureResponse
// @Router /auth/otp/send [post]
func (h *Handler) SendOTP(c *gin.Context) {
	var req SendOTPRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", []string{err.Error()})
		return
	}

	if err := h.svc.SendOTP(c.Request.Context(), req.Identifier, req.Type, req.Role); err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to send OTP", []string{err.Error()})
		return
	}

	utils.RespondSuccess(c, http.StatusOK, "OTP sent successfully", nil)
}

type VerifyOTPRequest struct {
	Identifier string `json:"identifier" binding:"required"`
	Type       string `json:"type" binding:"required,oneof=PHONE EMAIL"`
	Code       string `json:"code" binding:"required,len=6"`
}

// VerifyOTP handles POST /api/v1/auth/otp/verify
// @Summary Verify OTP
// @Description Verifies the OTP and returns a JWT token
// @Tags Auth
// @Accept json
// @Produce json
// @Param request body VerifyOTPRequest true "Verify OTP Request"
// @Success 200 {object} utils.SuccessResponse
// @Failure 400 {object} utils.FailureResponse
// @Router /auth/otp/verify [post]
func (h *Handler) VerifyOTP(c *gin.Context) {
	var req VerifyOTPRequest
	if err := c.ShouldBindJSON(&req); err != nil {
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
