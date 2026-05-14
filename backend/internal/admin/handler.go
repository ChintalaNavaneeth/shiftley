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

// GetManagementUsers handles GET /api/v1/admin/users
// @Summary Get Management Users
// @Description Fetches internal staff and admins
// @Tags Admin
// @Produce json
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /admin/users [get]
func (h *Handler) GetManagementUsers(c *gin.Context) {
	search := c.Query("query")
	roleFilter := c.Query("role")
	statusFilter := c.Query("status")

	query := h.db.Model(&auth.User{})

	// Base allowed roles for management
	roles := []string{
		string(auth.RoleSuperAdmin),
		string(auth.RoleAdmin),
		string(auth.RoleHRAdmin),
		string(auth.RoleCSAgent),
		string(auth.RoleAnalyst),
		string(auth.RoleVerifier),
	}

	if roleFilter != "" && roleFilter != "All Roles" {
		// Map UI labels to backend roles
		roleMap := map[string]string{
			"Super Admin":    string(auth.RoleSuperAdmin),
			"Business Admin": string(auth.RoleAdmin),
			"Verifier":       string(auth.RoleVerifier),
			"CS Agent":       string(auth.RoleCSAgent),
			"Analyst":        string(auth.RoleAnalyst),
		}
		if backendRole, ok := roleMap[roleFilter]; ok {
			query = query.Where("role = ?", backendRole)
		} else {
			// Fallback or exact match
			query = query.Where("role = ?", roleFilter)
		}
	} else {
		query = query.Where("role IN ?", roles)
	}

	if statusFilter != "" && statusFilter != "All Status" {
		if statusFilter == "Active" {
			query = query.Where("is_suspended = ?", false)
		} else if statusFilter == "Suspended" {
			query = query.Where("is_suspended = ?", true)
		}
	}

	if search != "" {
		searchTerm := "%" + search + "%"
		query = query.Where("full_name ILIKE ? OR email ILIKE ? OR phone_number LIKE ?", searchTerm, searchTerm, searchTerm)
	}

	var users []auth.User
	if err := query.Order("created_at DESC").Find(&users).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to fetch management users", nil)
		return
	}

	var response []map[string]interface{}
	for _, u := range users {
		status := "ACTIVE"
		if u.IsSuspended {
			status = "SUSPENDED"
		}
		response = append(response, map[string]interface{}{
			"id":           u.ID,
			"full_name":    u.FullName,
			"email":        u.Email,
			"phone_number": u.PhoneNumber,
			"role":         u.Role,
			"status":       status,
			"created_at":   u.CreatedAt,
		})
	}

	utils.RespondSuccess(c, http.StatusOK, response, nil)
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

// UpdateUser handles PATCH /api/v1/admin/users/{id}
func (h *Handler) UpdateUser(c *gin.Context) {
	id := c.Param("id")
	var req struct {
		FullName    string `json:"full_name"`
		Role        string `json:"role"`
		PhoneNumber string `json:"phone_number"`
		Email       string `json:"email"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", nil)
		return
	}

	updates := make(map[string]interface{})
	if req.FullName != "" {
		updates["full_name"] = req.FullName
	}
	if req.Role != "" {
		updates["role"] = req.Role
	}
	if req.PhoneNumber != "" {
		updates["phone_number"] = req.PhoneNumber
	}
	if req.Email != "" {
		updates["email"] = req.Email
	}

	if err := h.db.Model(&auth.User{}).Where("id = ?", id).Updates(updates).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to update user", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, nil, "User updated successfully")
}

// DeleteUser handles DELETE /api/v1/admin/users/{id}
func (h *Handler) DeleteUser(c *gin.Context) {
	id := c.Param("id")
	if err := h.db.Where("id = ?", id).Delete(&auth.User{}).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to delete user", nil)
		return
	}
	utils.RespondSuccess(c, http.StatusOK, nil, "User deleted successfully")
}

type ConfigUpdateRequest struct {
	EmployerSubscriptionMonthly float64 `json:"employer_subscription_monthly"`
	EmployerSubscriptionWeekly  float64 `json:"employer_subscription_weekly"`
	EmployerSubscriptionDaily   float64 `json:"employer_subscription_daily"`
	WorkerNoShowPenalty         float64 `json:"worker_no_show_penalty"`
	EmployerCancelPenalty6h     float64 `json:"employer_cancel_penalty_6h"`
	EmployerCancelPenalty3h     float64 `json:"employer_cancel_penalty_3h"`
	EmployerCancelPenalty1h     float64 `json:"employer_cancel_penalty_1h"`
	EmployerCancelBaseFine     float64 `json:"employer_cancel_base_fine"`
}

// GetPlatformConfig handles GET /api/v1/admin/config
func (h *Handler) GetPlatformConfig(c *gin.Context) {
	var conf config.PlatformConfig
	h.db.FirstOrCreate(&conf)

	// Fetch actual prices from the plans table to ensure UI consistency
	var daily, weekly, monthly int64
	h.db.Table("shiftley.subscription_plans").Where("id = ?", "daily_access").Select("price_paise").Row().Scan(&daily)
	h.db.Table("shiftley.subscription_plans").Where("id = ?", "weekly_unlimited").Select("price_paise").Row().Scan(&weekly)
	h.db.Table("shiftley.subscription_plans").Where("id = ?", "monthly_unlimited").Select("price_paise").Row().Scan(&monthly)

	// Inject into response for the Admin UI
	conf.EmployerSubscriptionDaily = float64(daily) / 100.0
	conf.EmployerSubscriptionWeekly = float64(weekly) / 100.0
	conf.EmployerSubscriptionMonthly = float64(monthly) / 100.0

	utils.RespondSuccess(c, http.StatusOK, conf, nil)
}

// UpdatePlatformConfig handles PATCH /api/v1/admin/config
// @Summary Update Platform Configuration
// @Description Updates global business variables like platform cuts or fees.
// @Tags Admin
// @Accept json
// @Produce json
// @Param request body ConfigUpdateRequest true "Config Updates"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /admin/config [patch]
func (h *Handler) UpdatePlatformConfig(c *gin.Context) {
	var req ConfigUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", nil)
		return
	}

	var conf config.PlatformConfig
	h.db.FirstOrCreate(&conf) // Ensure at least one record exists

	// Update fields if provided in request
	if req.WorkerNoShowPenalty > 0 {
		conf.WorkerNoShowPenalty = req.WorkerNoShowPenalty
	}
	if req.EmployerCancelPenalty6h > 0 {
		conf.EmployerCancelPenalty6h = req.EmployerCancelPenalty6h
	}
	if req.EmployerCancelPenalty3h > 0 {
		conf.EmployerCancelPenalty3h = req.EmployerCancelPenalty3h
	}
	if req.EmployerCancelPenalty1h > 0 {
		conf.EmployerCancelPenalty1h = req.EmployerCancelPenalty1h
	}
	if req.EmployerCancelBaseFine > 0 {
		conf.EmployerCancelBaseFine = req.EmployerCancelBaseFine
	}

	if err := h.db.Save(&conf).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to update configuration", nil)
		return
	}

	// Sync to shiftley.subscription_plans table to ensure Employer Dashboard sees the changes
	// We use the raw table name string to avoid circular imports with the employer package
	planTable := "shiftley.subscription_plans"
	if req.EmployerSubscriptionDaily > 0 {
		val := int64(req.EmployerSubscriptionDaily * 100)
		fmt.Printf("[DEBUG] Syncing Daily Plan: %v Rupee -> %d Paise\n", req.EmployerSubscriptionDaily, val)
		h.db.Debug().Table(planTable).Where("id = ?", "daily_access").Update("price_paise", val)
	}
	if req.EmployerSubscriptionWeekly > 0 {
		val := int64(req.EmployerSubscriptionWeekly * 100)
		fmt.Printf("[DEBUG] Syncing Weekly Plan: %v Rupee -> %d Paise\n", req.EmployerSubscriptionWeekly, val)
		h.db.Debug().Table(planTable).Where("id = ?", "weekly_unlimited").Update("price_paise", val)
	}
	if req.EmployerSubscriptionMonthly > 0 {
		val := int64(req.EmployerSubscriptionMonthly * 100)
		fmt.Printf("[DEBUG] Syncing Monthly Plan: %v Rupee -> %d Paise\n", req.EmployerSubscriptionMonthly, val)
		h.db.Debug().Table(planTable).Where("id = ?", "monthly_unlimited").Update("price_paise", val)
	}

	utils.RespondSuccess(c, http.StatusOK, conf, "Configuration updated successfully")
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

	// Allow creating all management roles except SUPER_ADMIN
	allowedRoles := map[string]bool{
		string(auth.RoleAdmin):    true,
		string(auth.RoleHRAdmin):  true,
		string(auth.RoleCSAgent):  true,
		string(auth.RoleAnalyst):  true,
		string(auth.RoleVerifier): true,
	}

	if !allowedRoles[req.Role] {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid role or restricted role creation", nil)
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
