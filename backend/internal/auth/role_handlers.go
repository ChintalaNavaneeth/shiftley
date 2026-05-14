package auth

import (
	"net/http"
	"shiftley/pkg/utils"

	"github.com/gin-gonic/gin"
)

// AdminSendOTP handles POST /api/v1/auth/admin/otp/send
func (h *Handler) AdminSendOTP(c *gin.Context) {
	var req SendOTPRequest
	if err := c.ShouldBind(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", []string{err.Error()})
		return
	}
	// Force role to ADMIN for this endpoint
	req.Role = "ADMIN"
	h.handleSendOTP(c, req)
}

// EmployerSendOTP handles POST /api/v1/auth/employer/otp/send
func (h *Handler) EmployerSendOTP(c *gin.Context) {
	var req SendOTPRequest
	if err := c.ShouldBind(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", []string{err.Error()})
		return
	}
	req.Role = string(RoleEmployer)
	h.handleSendOTP(c, req)
}

// VerifierSendOTP handles POST /api/v1/auth/verifier/otp/send
func (h *Handler) VerifierSendOTP(c *gin.Context) {
	var req SendOTPRequest
	if err := c.ShouldBind(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", []string{err.Error()})
		return
	}
	req.Role = string(RoleVerifier)
	h.handleSendOTP(c, req)
}

// AdminVerifyOTP handles POST /api/v1/auth/admin/otp/verify
func (h *Handler) AdminVerifyOTP(c *gin.Context) {
	var req VerifyOTPRequest
	if err := c.ShouldBind(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", []string{err.Error()})
		return
	}
	req.Role = "ADMIN"
	h.handleVerifyOTP(c, req)
}

// EmployerVerifyOTP handles POST /api/v1/auth/employer/otp/verify
func (h *Handler) EmployerVerifyOTP(c *gin.Context) {
	var req VerifyOTPRequest
	if err := c.ShouldBind(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", []string{err.Error()})
		return
	}
	req.Role = string(RoleEmployer)
	h.handleVerifyOTP(c, req)
}

// VerifierVerifyOTP handles POST /api/v1/auth/verifier/otp/verify
func (h *Handler) VerifierVerifyOTP(c *gin.Context) {
	var req VerifyOTPRequest
	if err := c.ShouldBind(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", []string{err.Error()})
		return
	}
	req.Role = string(RoleVerifier)
	h.handleVerifyOTP(c, req)
}

// Internal helpers to avoid duplication while keeping endpoints separate
func (h *Handler) handleSendOTP(c *gin.Context, req SendOTPRequest) {
	code, err := h.svc.SendOTP(c.Request.Context(), req.Identifier, req.Type, req.Role)
	if err != nil {
		utils.RespondError(c, http.StatusForbidden, utils.ErrForbidden, err.Error(), nil)
		return
	}

	// Logic for dual-channel delivery (shared)
	var user User
	if err := h.db.Where("email = ? OR phone_number = ?", req.Identifier, req.Identifier).First(&user).Error; err == nil {
		if user.PhoneNumber != "" {
			h.notify.SendOTP(user.PhoneNumber, code)
		}
	} else {
		h.notify.SendOTP(req.Identifier, code)
	}

	utils.RespondSuccess(c, http.StatusOK, "OTP sent successfully", nil)
}

func (h *Handler) handleVerifyOTP(c *gin.Context, req VerifyOTPRequest) {
	accessToken, refreshToken, isNewUser, user, err := h.svc.VerifyOTP(c.Request.Context(), req.Identifier, req.Type, req.Code, req.Role)
	if err != nil {
		utils.RespondError(c, http.StatusUnauthorized, utils.ErrUnauthorized, err.Error(), nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"is_new_user":               isNewUser,
		"access_token":              accessToken,
		"registration_token":        accessToken, // Support both for frontend compatibility
		"refresh_token":             refreshToken,
		"is_initial_setup_complete": user.IsInitialSetupComplete,
		"user": gin.H{
			"id":          user.ID,
			"role":        user.Role,
			"is_verified": user.IsVerified,
		},
	}, nil)
}
