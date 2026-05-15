package employee

import (
	"fmt"
	"net/http"
	"time"

	"shiftley/internal/auth"
	"shiftley/internal/gig"
	"shiftley/pkg/utils"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/lib/pq"
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

	// 1. Total Gigs (Approved or Completed)
	var totalGigs int64
	h.db.Model(&gig.GigApplication{}).Where("employee_id = ? AND status IN ?", userID, []string{"APPROVED", "COMPLETED"}).Count(&totalGigs)

	// 2. No Shows
	var noShows int64
	h.db.Model(&gig.GigApplication{}).Where("employee_id = ? AND status = ?", userID, "NO_SHOW").Count(&noShows)

	// 3. Earnings (Sum of wage_per_worker for COMPLETED gigs)
	var totalEarned int64
	h.db.Table("shiftley.gig_applications").
		Select("COALESCE(SUM(gigs.wage_per_worker), 0)").
		Joins("JOIN shiftley.gigs ON gigs.id = gig_applications.gig_id").
		Where("gig_applications.employee_id = ? AND gig_applications.status = ?", userID, "COMPLETED").
		Row().Scan(&totalEarned)

	// 4. This Month Earnings
	var thisMonthEarned int64
	firstOfMonth := time.Now().AddDate(0, 0, -time.Now().Day()+1)
	h.db.Table("shiftley.gig_applications").
		Select("COALESCE(SUM(gigs.wage_per_worker), 0)").
		Joins("JOIN shiftley.gigs ON gigs.id = gig_applications.gig_id").
		Where("gig_applications.employee_id = ? AND gig_applications.status = ? AND gig_applications.updated_at >= ?", userID, "COMPLETED", firstOfMonth).
		Row().Scan(&thisMonthEarned)

	// 5. Next Shift
	var nextApps []gig.GigApplication
	h.db.Preload("Gig").
		Joins("JOIN shiftley.gigs ON gigs.id = gig_applications.gig_id").
		Where("gig_applications.employee_id = ? AND gig_applications.status = ? AND gigs.start_time > ?", userID, "APPROVED", time.Now()).
		Order("gigs.start_time ASC").
		Limit(1).
		Find(&nextApps)

	var nextShift interface{} = nil
	if len(nextApps) > 0 {
		nextShift = nextApps[0].Gig
	}

	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"employee_id":             user.ID,
		"full_name":               user.FullName,
		"overall_rating":          4.8, // Mock for now until reviews are integrated
		"reliability_status":      "GOOD",
		"active_fine_paise":       user.UnpaidFinePaise,
		"total_gigs":              totalGigs,
		"total_earned_paise":      totalEarned,
		"this_month_earned_paise": thisMonthEarned,
		"no_shows":                noShows,
		"next_shift":              nextShift,
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

// DeleteSkill handles DELETE /api/v1/employees/me/skills/:skillId
func (h *Handler) DeleteSkill(c *gin.Context) {
	userIDStr, _ := c.Get("userID")
	userID, _ := uuid.Parse(userIDStr.(string))
	skillID := c.Param("skillId")

	var wp auth.WorkerProfile
	if err := h.db.First(&wp, "user_id = ?", userID).Error; err != nil {
		utils.RespondError(c, http.StatusNotFound, utils.ErrNotFound, "Profile not found", nil)
		return
	}

	newSkills := []string{}
	for _, s := range wp.Skills {
		if s != skillID {
			newSkills = append(newSkills, s)
		}
	}

	if err := h.db.Model(&wp).Update("skills", pq.StringArray(newSkills)).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to update skills", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, "Skill removed", nil)
}

// DeleteCertification handles DELETE /api/v1/employees/me/certifications/:certId
func (h *Handler) DeleteCertification(c *gin.Context) {
	userIDStr, _ := c.Get("userID")
	userID, _ := uuid.Parse(userIDStr.(string))
	certID := c.Param("certId")

	if err := h.db.Where("id = ? AND user_id = ?", certID, userID).Delete(&auth.Certification{}).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to delete certification", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, "Certification removed", nil)
}

// AddSkill handles POST /api/v1/employees/me/skills
func (h *Handler) AddSkill(c *gin.Context) {
	userIDStr, _ := c.Get("userID")
	userID, _ := uuid.Parse(userIDStr.(string))

	var req struct {
		SkillID string `json:"skill_id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request", nil)
		return
	}

	var wp auth.WorkerProfile
	if err := h.db.First(&wp, "user_id = ?", userID).Error; err != nil {
		utils.RespondError(c, http.StatusNotFound, utils.ErrNotFound, "Profile not found", nil)
		return
	}

	// Check if already exists
	for _, s := range wp.Skills {
		if s == req.SkillID {
			utils.RespondSuccess(c, http.StatusOK, "Skill already exists", nil)
			return
		}
	}

	wp.Skills = append(wp.Skills, req.SkillID)

	if err := h.db.Model(&wp).Update("skills", pq.StringArray(wp.Skills)).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to add skill", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, "Skill added", nil)
}

// AddCertification handles POST /api/v1/employees/me/certifications
func (h *Handler) AddCertification(c *gin.Context) {
	userIDStr, _ := c.Get("userID")
	userID, _ := uuid.Parse(userIDStr.(string))

	var cert auth.Certification
	if err := c.ShouldBindJSON(&cert); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request", nil)
		return
	}

	cert.UserID = userID
	cert.ID = uuid.New()

	if err := h.db.Create(&cert).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to add certification", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, cert, nil)
}
