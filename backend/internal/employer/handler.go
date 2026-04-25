package employer

import (
	"fmt"
	"net/http"
	"time"

	"shiftley/internal/auth"
	"shiftley/internal/gig"
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

// GetProfile handles GET /api/v1/employers/me
// @Summary Employer Dashboard Profile
// @Description Fetches employer details and business metrics.
// @Tags Employer
// @Produce json
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /employers/me [get]
func (h *Handler) GetProfile(c *gin.Context) {
	userIDStr, _ := c.Get("userID")
	userID, _ := uuid.Parse(userIDStr.(string))

	var user auth.User
	if err := h.db.First(&user, userID).Error; err != nil {
		utils.RespondError(c, http.StatusNotFound, utils.ErrNotFound, "User not found", nil)
		return
	}

	// Calculate Stats
	var totalGigs int64
	h.db.Model(&gig.Gig{}).Where("employer_id = ?", userID).Count(&totalGigs)

	var activeSub Subscription
	err := h.db.Where("employer_id = ? AND is_active = ? AND end_date > ?", userID, true, time.Now()).
		Order("end_date DESC").First(&activeSub).Error

	stats := EmployerStats{
		TotalGigsPosted:   totalGigs,
		FreeGigsRemaining: 5 - int(totalGigs), // Mock logic: 5 free gigs
		ActivePlan:        PlanNone,
	}
	if stats.FreeGigsRemaining < 0 {
		stats.FreeGigsRemaining = 0
	}

	if err == nil {
		stats.ActivePlan = activeSub.PlanID
		stats.PlanExpiresAt = &activeSub.EndDate
	}

	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"profile": user,
		"stats":   stats,
	}, nil)
}

// PurchaseSubscription handles POST /api/v1/employers/me/subscription
// @Summary Purchase Subscription Plan
// @Description Generates a mock Razorpay Order ID for subscription purchase.
// @Tags Employer
// @Accept json
// @Produce json
// @Param request body object true "Plan Details"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /employers/me/subscription [post]
func (h *Handler) PurchaseSubscription(c *gin.Context) {
	var req struct {
		PlanID string `json:"plan_id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid plan_id", nil)
		return
	}

	// Mock Razorpay Order Generation
	mockOrderID := fmt.Sprintf("order_sub_%s", uuid.New().String()[:8])

	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"razorpay_order_id": mockOrderID,
		"plan_id":           req.PlanID,
		"message":           "Proceed to payment with the generated Order ID",
	}, nil)
}

// GetMyGigs handles GET /api/v1/employers/me/gigs
// @Summary View My Gigs (History & Active)
// @Description Fetches employer's gig history with status filtering.
// @Tags Employer
// @Produce json
// @Param status query string false "Gig Status"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /employers/me/gigs [get]
func (h *Handler) GetMyGigs(c *gin.Context) {
	userIDStr, _ := c.Get("userID")
	userID, _ := uuid.Parse(userIDStr.(string))
	status := c.Query("status")

	var gigs []gig.Gig
	query := h.db.Where("employer_id = ?", userID)
	if status != "" {
		query = query.Where("status = ?", status)
	}

	if err := query.Order("created_at DESC").Find(&gigs).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to fetch gigs", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, gigs, nil)
}

// GetEmployeeProfile handles GET /api/v1/employers/profiles/employees/:empId
// @Summary View Full Worker Profile
// @Description Fetches detailed resume and past feedback of a worker.
// @Tags Employer
// @Produce json
// @Param empId path string true "Employee User ID"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /employers/profiles/employees/{empId} [get]
func (h *Handler) GetEmployeeProfile(c *gin.Context) {
	empIDStr := c.Param("empId")
	empID, err := uuid.Parse(empIDStr)
	if err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid employee ID", nil)
		return
	}

	var employee auth.User
	if err := h.db.First(&employee, empID).Error; err != nil {
		utils.RespondError(c, http.StatusNotFound, utils.ErrNotFound, "Employee not found", nil)
		return
	}

	var reviews []gig.GigReview
	h.db.Where("to_user_id = ?", empID).Order("created_at DESC").Limit(5).Find(&reviews)

	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"profile":         employee,
		"recent_feedback": reviews,
	}, nil)
}

