package employee

import (
	"fmt"
	"net/http"

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

// GetProfile handles GET /api/v1/employees/me
// @Summary Employee Dashboard Data
// @Description Returns rating, reliability status, and active fines.
// @Tags Employee
// @Produce json
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /employees/me [get]
func (h *Handler) GetProfile(c *gin.Context) {
	userIDStr, _ := c.Get("userID")
	userID, _ := uuid.Parse(userIDStr.(string))

	var user auth.User
	if err := h.db.First(&user, userID).Error; err != nil {
		utils.RespondError(c, http.StatusNotFound, utils.ErrNotFound, "User not found", nil)
		return
	}

	// Mock rating/reliability for now
	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"employee_id":        user.ID,
		"full_name":          user.FullName,
		"overall_rating":     4.8,
		"reliability_status": "GOOD",
		"active_fine_paise":  user.UnpaidFinePaise,
	}, nil)
}

// GetSchedule handles GET /api/v1/employees/me/schedule
// @Summary View Upcoming Shifts
// @Description Returns confirmed upcoming gigs for the worker.
// @Tags Employee
// @Produce json
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /employees/me/schedule [get]
func (h *Handler) GetSchedule(c *gin.Context) {
	userIDStr, _ := c.Get("userID")
	userID, _ := uuid.Parse(userIDStr.(string))

	var apps []gig.GigApplication
	if err := h.db.Preload("Gig").Where("employee_id = ? AND status = ?", userID, gig.AppApproved).Find(&apps).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to fetch schedule", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, apps, nil)
}

// UpdatePayoutMethods handles PUT /api/v1/employees/me/payout-methods
// @Summary Update Payout Profile
// @Description Saves UPI or Bank details for payments.
// @Tags Employee
// @Accept json
// @Produce json
// @Param request body object true "Payout Details"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /employees/me/payout-methods [put]
func (h *Handler) UpdatePayoutMethods(c *gin.Context) {
	userIDStr, _ := c.Get("userID")
	userID, _ := uuid.Parse(userIDStr.(string))

	var req struct {
		Type        string `json:"type" binding:"required,oneof=UPI BANK"`
		UPIID       string `json:"upi_id"`
		BankAccount string `json:"bank_account"`
		BankIFSC    string `json:"bank_ifsc"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request", nil)
		return
	}

	updates := map[string]interface{}{
		"upi_id":       req.UPIID,
		"bank_account": req.BankAccount,
		"bank_ifsc":    req.BankIFSC,
	}

	if err := h.db.Model(&auth.User{}).Where("id = ?", userID).Updates(updates).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to update payout methods", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, "Payout method updated successfully", nil)
}

// PayPenalty handles POST /api/v1/employees/me/pay-penalty
// @Summary Generate Razorpay Order for Fine
// @Description Returns a Razorpay order ID to clear no-show fines.
// @Tags Employee
// @Produce json
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /employees/me/pay-penalty [post]
func (h *Handler) PayPenalty(c *gin.Context) {
	userIDStr, _ := c.Get("userID")
	userID, _ := uuid.Parse(userIDStr.(string))

	var user auth.User
	if err := h.db.First(&user, userID).Error; err != nil {
		utils.RespondError(c, http.StatusNotFound, utils.ErrNotFound, "User not found", nil)
		return
	}

	if user.UnpaidFinePaise == 0 {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "No active fines", nil)
		return
	}

	// Mock Razorpay Order
	orderID := fmt.Sprintf("order_fine_%s", uuid.New().String()[:8])
	
	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"razorpay_order_id": orderID,
		"amount_paise":      user.UnpaidFinePaise,
	}, nil)
}
