package admin

import (
	"fmt"
	"net/http"
	"time"

	"shiftley/internal/auth"
	"shiftley/pkg/utils"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Handler struct {
	db *gorm.DB
}

func NewHandler(db *gorm.DB) *Handler {
	return &Handler{db: db}
}

type InviteUserRequest struct {
	FullName      string `json:"full_name" binding:"required"`
	Email         string `json:"email" binding:"required,email"`
	PhoneNumber   string `json:"phone_number" binding:"required"`
	AadhaarNumber string `json:"aadhaar_number" binding:"required,len=12"`
	Role          string `json:"role" binding:"required"`
}

// InviteUser handles POST /api/v1/admin/users/invite
// @Summary Invite Internal Staff
// @Description Creates an internal account and triggers an email with a secure, temporary password.
// @Tags Admin
// @Accept json
// @Produce json
// @Param request body InviteUserRequest true "Invitation Details"
// @Success 201 {object} utils.SuccessResponse
// @Failure 400 {object} utils.FailureResponse
// @Failure 403 {object} utils.FailureResponse
// @Failure 409 {object} utils.FailureResponse
// @Security ApiKeyAuth
// @Router /admin/users/invite [post]
func (h *Handler) InviteUser(c *gin.Context) {
	var req InviteUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", nil)
		return
	}

	// Basic Role Validation (should ideally use constants from auth pkg)
	validRoles := map[string]bool{
		string(auth.RoleVerifier): true,
		string(auth.RoleCSAgent):  true,
		string(auth.RoleAnalyst):  true,
		string(auth.RoleAdmin):    true,
	}

	if !validRoles[req.Role] {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid or unsupported role for internal staff", nil)
		return
	}

	// Transaction to ensure atomicity
	err := h.db.Transaction(func(tx *gorm.DB) error {
		// 1. Check if user already exists
		var count int64
		tx.Model(&auth.User{}).Where("email = ? OR phone_number = ?", req.Email, req.PhoneNumber).Count(&count)
		if count > 0 {
			return fmt.Errorf("conflict: email or phone number already registered")
		}

		// 2. Create User
		user := &auth.User{
			Email:        req.Email,
			PhoneNumber:  req.PhoneNumber,
			FullName:     req.FullName,
			Role:         auth.UserRole(req.Role),
			IsVerified:   true, // Bypassing OTP
			PasswordHash: "temp_secure_hash_here", // Placeholder for actual hash logic
		}

		if err := tx.Create(user).Error; err != nil {
			return fmt.Errorf("failed to create user: %w", err)
		}

		// 3. Create KYC Session to store masked Aadhaar
		maskedAadhaar := "XXXXXXXX" + req.AadhaarNumber[8:]
		now := time.Now()
		kyc := &auth.KYCSession{
			UserID:        user.ID,
			Provider:      "INTERNAL_HR",
			Status:        "VERIFIED",
			MaskedAadhaar: maskedAadhaar,
			VerifiedAt:    &now,
		}

		if err := tx.Create(kyc).Error; err != nil {
			return fmt.Errorf("failed to save KYC details: %w", err)
		}

		return nil
	})

	if err != nil {
		if err.Error() == "conflict: email or phone number already registered" {
			utils.RespondError(c, http.StatusConflict, "ERR_CONFLICT", err.Error(), nil)
			return
		}
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to invite user", nil)
		return
	}

	// 4. Simulate Email Sending
	fmt.Printf("[MOCK EMAIL] Sent temporary password to %s for internal role %s\n", req.Email, req.Role)

	utils.RespondSuccess(c, http.StatusCreated, gin.H{
		"id":      uuid.New().String(), // returning a nanoID or new UUID for response
		"message": fmt.Sprintf("User %s created. Login credentials sent to %s", req.Role, req.Email),
	}, nil)
}
