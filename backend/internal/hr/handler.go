package hr

import (
	"fmt"
	"net/http"
	"time"

	"shiftley/internal/auth"
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

// CreateStaff handles POST /api/v1/hr/staff
func (h *Handler) CreateStaff(c *gin.Context) {
	var req struct {
		FullName     string `json:"full_name" binding:"required"`
		Email        string `json:"email" binding:"required,email"`
		Phone        string `json:"phone" binding:"required"`
		InternalRole string `json:"internal_role" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request", nil)
		return
	}

	// Validate internal roles only
	validRoles := map[string]bool{
		string(auth.RoleVerifier): true,
		string(auth.RoleCSAgent):  true,
		string(auth.RoleAnalyst):  true,
	}

	if !validRoles[req.InternalRole] {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid internal staff role", nil)
		return
	}

	staff := auth.User{
		FullName:     req.FullName,
		Email:        req.Email,
		PhoneNumber:  req.Phone,
		Role:         auth.UserRole(req.InternalRole),
		IsVerified:   true,
		PasswordHash: "temp_secure_staff_hash", // Mock
	}

	if err := h.db.Create(&staff).Error; err != nil {
		utils.RespondError(c, http.StatusConflict, "ERR_CONFLICT", "Staff already exists", nil)
		return
	}

	fmt.Printf("[MOCK EMAIL] Sent onboarding link to %s\n", req.Email)
	utils.RespondSuccess(c, http.StatusCreated, staff, nil)
}

// GetStaffRoster handles GET /api/v1/hr/staff
func (h *Handler) GetStaffRoster(c *gin.Context) {
	role := c.Query("role")
	status := c.Query("status")

	var staff []auth.User
	query := h.db.Model(&auth.User{}).Where("role IN ?", []string{
		string(auth.RoleVerifier),
		string(auth.RoleCSAgent),
		string(auth.RoleAnalyst),
	})

	if role != "" {
		query = query.Where("role = ?", role)
	}
	if status == "SUSPENDED" {
		query = query.Where("is_suspended = ?", true)
	} else if status == "ACTIVE" {
		query = query.Where("is_suspended = ?", false)
	}

	if err := query.Find(&staff).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to fetch roster", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, staff, nil)
}

// UpdateStaffStatus handles PATCH /api/v1/hr/staff/:id/status
func (h *Handler) UpdateStaffStatus(c *gin.Context) {
	staffID := c.Param("id")
	var req struct {
		Status string `json:"status" binding:"required,oneof=ACTIVE SUSPENDED TERMINATED"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid status", nil)
		return
	}

	isSuspended := req.Status == "SUSPENDED" || req.Status == "TERMINATED"

	if err := h.db.Model(&auth.User{}).Where("id = ?", staffID).Update("is_suspended", isSuspended).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to update staff status", nil)
		return
	}

	// Invalidate session
	if isSuspended {
		h.rdb.Set(c.Request.Context(), "blacklist:"+staffID, req.Status, 24*time.Hour)
	}

	utils.RespondSuccess(c, http.StatusOK, gin.H{"id": staffID, "status": req.Status}, nil)
}
