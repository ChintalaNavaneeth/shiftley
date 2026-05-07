package admin

import (
	"fmt"
	"net/http"
	"time"

	"shiftley/internal/auth"
	"shiftley/internal/config"
	"shiftley/internal/cs"
	"shiftley/pkg/utils"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"
	"gorm.io/gorm"
)

type Handler struct {
	db  *gorm.DB
	rdb *redis.Client
}

func NewHandler(db *gorm.DB, rdb *redis.Client) *Handler {
	return &Handler{db: db, rdb: rdb}
}

type UserStatusRequest struct {
	Status string `json:"status" binding:"required"` // SUSPENDED, ACTIVE
	Reason string `json:"reason"`
}

// UpdateUserStatus handles PATCH /api/v1/admin/users/{id}/status
// @Summary Revoke / Ban User
// @Description Instantly revokes access for staff or public users.
// @Tags Admin
// @Accept json
// @Produce json
// @Param id path string true "User ID"
// @Param request body UserStatusRequest true "Status Update"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /admin/users/{id}/status [patch]
func (h *Handler) UpdateUserStatus(c *gin.Context) {
	id := c.Param("id")
	var req UserStatusRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", nil)
		return
	}

	isSuspended := req.Status == "SUSPENDED"

	if err := h.db.Model(&auth.User{}).Where("id = ?", id).Update("is_suspended", isSuspended).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to update user status", nil)
		return
	}

	// Invalidate JWT by blacklisting in Redis
	if isSuspended {
		// Blacklist for 24 hours (typical max token duration)
		h.rdb.Set(c.Request.Context(), "blacklist:"+id, "suspended", 24*time.Hour)
	} else {
		h.rdb.Del(c.Request.Context(), "blacklist:"+id)
	}

	utils.RespondSuccess(c, http.StatusOK, gin.H{"id": id, "status": req.Status}, nil)
}

type ConfigUpdateRequest struct {
	EmployerSubscriptionMonthly float64 `json:"employer_subscription_monthly"`
	EmployerSubscriptionWeekly  float64 `json:"employer_subscription_weekly"`
	EmployerPerDayFee           float64 `json:"employer_per_day_fee"`
	WorkerCancelPenalty         float64 `json:"worker_cancel_penalty"`
}

// UpdatePlatformConfig handles PATCH /api/v1/admin/config/fees
// @Summary Update Platform Configuration
// @Description Updates global business variables like platform cuts or fees.
// @Tags Admin
// @Accept json
// @Produce json
// @Param request body ConfigUpdateRequest true "Config Updates"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /admin/config/fees [patch]
func (h *Handler) UpdatePlatformConfig(c *gin.Context) {
	var req ConfigUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", nil)
		return
	}

	var conf config.PlatformConfig
	h.db.FirstOrCreate(&conf) // Ensure at least one record exists

	// Update fields if provided in request
	if req.EmployerSubscriptionMonthly > 0 {
		conf.EmployerSubscriptionMonthly = req.EmployerSubscriptionMonthly
	}
	if req.EmployerSubscriptionWeekly > 0 {
		conf.EmployerSubscriptionWeekly = req.EmployerSubscriptionWeekly
	}
	if req.EmployerPerDayFee > 0 {
		conf.EmployerPerDayFee = req.EmployerPerDayFee
	}
	if req.WorkerCancelPenalty > 0 {
		conf.WorkerCancelPenalty = req.WorkerCancelPenalty
	}

	if err := h.db.Save(&conf).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to update configuration", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, conf, nil)
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
			PasswordHash: fmt.Sprintf("$2a$10$temporary_hash_%s", uuid.New().String()[:8]),
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

type ManagementUserRequest struct {
	FullName    string `json:"full_name" binding:"required"`
	Email       string `json:"email" binding:"required,email"`
	PhoneNumber string `json:"phone_number" binding:"required"`
	Role        string `json:"role" binding:"required"`
}

// CreateManagementUser handles POST /api/v1/admin/super/users
// @Summary Create Management Roles
// @Description Creates ADMIN and HR_ADMIN accounts. Restricted to SUPER_ADMIN.
// @Tags Admin
// @Accept json
// @Produce json
// @Param request body ManagementUserRequest true "Management User Details"
// @Success 201 {object} utils.SuccessResponse
// @Failure 400 {object} utils.FailureResponse
// @Failure 403 {object} utils.FailureResponse
// @Security ApiKeyAuth
// @Router /admin/super/users [post]
func (h *Handler) CreateManagementUser(c *gin.Context) {
	var req ManagementUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", nil)
		return
	}

	// Only ADMIN and HR_ADMIN can be created via this endpoint
	if req.Role != string(auth.RoleAdmin) && req.Role != string(auth.RoleHRAdmin) {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Only ADMIN and HR_ADMIN roles can be created here", nil)
		return
	}

	// 1. Check if user already exists
	var count int64
	h.db.Model(&auth.User{}).Where("email = ? OR phone_number = ?", req.Email, req.PhoneNumber).Count(&count)
	if count > 0 {
		utils.RespondError(c, http.StatusConflict, "ERR_CONFLICT", "Email or phone number already registered", nil)
		return
	}

	// 2. Create User
	user := &auth.User{
		Email:        req.Email,
		PhoneNumber:  req.PhoneNumber,
		FullName:     req.FullName,
		Role:         auth.UserRole(req.Role),
		IsVerified:   true,
		PasswordHash: "management_temp_hash", // Placeholder
	}

	if err := h.db.Create(user).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to create management user", nil)
		return
	}

	// 3. Simulate Email Sending
	fmt.Printf("[MOCK EMAIL] Sent management credentials to %s for role %s\n", req.Email, req.Role)

	utils.RespondSuccess(c, http.StatusCreated, gin.H{
		"id":      uuid.New().String(),
		"message": fmt.Sprintf("Management User %s created. Login credentials sent to %s", req.Role, req.Email),
	}, nil)
}

type SuperAdminSetupRequest struct {
	FullName    string `json:"full_name" binding:"required"`
	Email       string `json:"email" binding:"required,email"`
	PhoneNumber string `json:"phone_number" binding:"required"`
}

// UpdateSuperAdminSetup handles PATCH /api/v1/admin/super/setup
// @Summary Super Admin Initial Setup
// @Description Updates root admin details and marks setup as complete. Can only be done once.
// @Tags Admin
// @Accept json
// @Produce json
// @Param request body SuperAdminSetupRequest true "Setup Details"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /admin/super/setup [patch]
func (h *Handler) UpdateSuperAdminSetup(c *gin.Context) {
	userIDVal, _ := c.Get("userID")
	userIDStr := userIDVal.(string)

	var user auth.User
	if err := h.db.First(&user, "id = ?", userIDStr).Error; err != nil {
		utils.RespondError(c, http.StatusNotFound, "USER_NOT_FOUND", "User not found", nil)
		return
	}

	if user.Role != auth.RoleSuperAdmin {
		utils.RespondError(c, http.StatusForbidden, "FORBIDDEN", "Only Super Admin can access this", nil)
		return
	}

	if user.IsInitialSetupComplete {
		utils.RespondError(c, http.StatusForbidden, "SETUP_ALREADY_COMPLETE", "Initial setup has already been completed", nil)
		return
	}

	var req SuperAdminSetupRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", nil)
		return
	}

	// 1. Check for Conflicts (exclude current user)
	var conflictCount int64
	h.db.Model(&auth.User{}).
		Where("(email = ? OR phone_number = ?) AND id != ?", req.Email, req.PhoneNumber, userIDStr).
		Count(&conflictCount)

	if conflictCount > 0 {
		utils.RespondError(c, http.StatusConflict, "ERR_CONFLICT", "The provided email or phone number is already registered to another account. Please use a different identifier or login with that account.", nil)
		return
	}

	// 2. Update user details
	updates := map[string]interface{}{
		"full_name":                 req.FullName,
		"email":                     req.Email,
		"phone_number":              req.PhoneNumber,
		"is_verified":               true,
		"is_initial_setup_complete": true,
	}

	if err := h.db.Model(&user).Updates(updates).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to complete setup", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"message":                   "Super Admin setup complete. Your credentials have been updated.",
		"is_initial_setup_complete": true,
	}, nil)
}
// GetPendingDisputes handles GET /api/v1/admin/disputes/pending
func (h *Handler) GetPendingDisputes(c *gin.Context) {
	var requests []cs.DisputeResolutionRequest
	if err := h.db.Where("status = ?", cs.StatusPending).Order("created_at ASC").Find(&requests).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to fetch pending disputes", nil)
		return
	}
	utils.RespondSuccess(c, http.StatusOK, requests, nil)
}

// ResolveDispute handles POST /api/v1/admin/disputes/:id/resolve
func (h *Handler) ResolveDispute(c *gin.Context) {
	id := c.Param("id")
	adminIDVal, _ := c.Get("userID")
	adminID, _ := uuid.Parse(adminIDVal.(string))

	var req struct {
		Action string `json:"action" binding:"required"` // APPROVE, REJECT
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Action (APPROVE/REJECT) required", nil)
		return
	}

	var resReq cs.DisputeResolutionRequest
	if err := h.db.First(&resReq, "id = ?", id).Error; err != nil {
		utils.RespondError(c, http.StatusNotFound, utils.ErrNotFound, "Dispute request not found", nil)
		return
	}

	if resReq.Status != cs.StatusPending {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Request is already processed", nil)
		return
	}

	// Process based on action
	if req.Action == "APPROVE" {
		resReq.Status = cs.StatusApproved
		// In a real scenario, this would trigger the Razorpay Route release or refund
		fmt.Printf("[ADMIN APPROVAL] Admin %s approved resolution for Request %s. Executing %s for %d paise\n",
			adminID, id, resReq.Recommendation, resReq.AmountPaise)
	} else {
		resReq.Status = cs.StatusRejected
	}

	resReq.AdminID = &adminID
	if err := h.db.Save(&resReq).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to save resolution", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, resReq, "Dispute resolved successfully")
}
