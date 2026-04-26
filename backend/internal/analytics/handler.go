package analytics

import (
	"net/http"
	"time"

	"shiftley/internal/auth"
	"shiftley/internal/employer"
	"shiftley/internal/gig"
	"shiftley/pkg/utils"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type Handler struct {
	db *gorm.DB
}

func NewHandler(db *gorm.DB) *Handler {
	return &Handler{db: db}
}

// GetOverview handles GET /api/v1/analytics/overview
func (h *Handler) GetOverview(c *gin.Context) {
	var employerCount, workerCount, gigPosted, gigCompleted int64

	h.db.Model(&auth.User{}).Where("role = ? AND is_verified = ?", auth.RoleEmployer, true).Count(&employerCount)
	h.db.Model(&auth.User{}).Where("role = ? AND is_verified = ?", auth.RoleWorker, true).Count(&workerCount)
	h.db.Model(&gig.Gig{}).Count(&gigPosted)
	h.db.Model(&gig.Gig{}).Where("status = ?", gig.StatusCompleted).Count(&gigCompleted)

	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"total_verified_employers": employerCount,
		"total_active_workers":     workerCount,
		"gigs_posted":              gigPosted,
		"gigs_completed":           gigCompleted,
	}, nil)
}

// GetFinancials handles GET /api/v1/analytics/financials
func (h *Handler) GetFinancials(c *gin.Context) {
	var subRevenue, fineRevenue, totalGMV int64

	// Subscriptions
	h.db.Model(&employer.Subscription{}).Select("COALESCE(SUM(amount_paise), 0)").Scan(&subRevenue)
	
	// Fines (Retained from cancellations or paid by workers)
	// Simplified: just sum all unpaid fines (mock) + retained earnings from cancellations
	h.db.Model(&auth.User{}).Select("COALESCE(SUM(unpaid_fine_paise), 0)").Scan(&fineRevenue)

	// total GMV (Wage of all completed gigs)
	h.db.Model(&gig.Gig{}).Where("status = ?", gig.StatusCompleted).Select("COALESCE(SUM(wage_per_worker * workers_needed), 0)").Scan(&totalGMV)

	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"current_escrow_load_paise":         totalGMV / 2, // Mock estimation
		"subscription_revenue_paise":        subRevenue,
		"retained_cancellation_fines_paise": fineRevenue,
		"total_worker_gmv_paise":            totalGMV,
	}, nil)
}

// GetLiquidity handles GET /api/v1/analytics/liquidity
func (h *Handler) GetLiquidity(c *gin.Context) {
	category := c.Query("skill_category")

	var totalGigs, filledGigs int64
	query := h.db.Model(&gig.Gig{})
	if category != "" {
		query = query.Where("category_id = ?", category)
	}
	query.Count(&totalGigs)
	query.Where("status IN ?", []gig.GigStatus{gig.StatusFilled, gig.StatusCompleted}).Count(&filledGigs)

	fillRate := 0.0
	if totalGigs > 0 {
		fillRate = float64(filledGigs) / float64(totalGigs) * 100
	}

	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"gig_fill_rate_percentage": fillRate,
		"worker_to_gig_ratio":      4.2, // Mock
		"most_demanded_skill":      "General Staff",
	}, nil)
}

// GetHealth handles GET /api/v1/analytics/health
func (h *Handler) GetHealth(c *gin.Context) {
	var totalApps, noShowApps int64
	h.db.Model(&gig.GigApplication{}).Count(&totalApps)
	h.db.Model(&gig.GigApplication{}).Where("status = ?", gig.AppNoShow).Count(&noShowApps)

	noShowRate := 0.0
	if totalApps > 0 {
		noShowRate = float64(noShowApps) / float64(totalApps) * 100
	}

	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"no_show_rate_percentage":           noShowRate,
		"emergency_trigger_rate_percentage": 4.5,
		"verifier_sla_breaches":             12,
	}, nil)
}

// GetCustomerServiceStats handles GET /api/v1/analytics/customer-service
func (h *Handler) GetCustomerServiceStats(c *gin.Context) {
	// Mock categories based on support tickets if they existed in detailed form
	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"total_cs_interventions": 142,
		"issues_by_category": gin.H{
			"PAYMENT_DISPUTE":    80,
			"VERIFICATION_DELAY": 42,
			"APP_BUG":            20,
		},
	}, nil)
}

// LogExpenditure handles POST /api/v1/analytics/expenditure
func (h *Handler) LogExpenditure(c *gin.Context) {
	var req struct {
		Month       string              `json:"month" binding:"required"`
		Category    ExpenditureCategory `json:"category" binding:"required"`
		AmountPaise int64               `json:"amount_paise" binding:"required"`
		Description string              `json:"description"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid input", nil)
		return
	}

	exp := Expenditure{
		Month:       req.Month,
		Category:    req.Category,
		AmountPaise: req.AmountPaise,
		Description: req.Description,
	}

	if err := h.db.Create(&exp).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to log expenditure", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusCreated, exp, nil)
}

// GetPnL handles GET /api/v1/analytics/pnl
func (h *Handler) GetPnL(c *gin.Context) {
	month := c.Query("month")
	if month == "" {
		month = time.Now().Format("2006-01")
	}

	var subRevenue, fineRevenue, totalExp int64

	// Revenue
	h.db.Model(&employer.Subscription{}).Where("TO_CHAR(created_at, 'YYYY-MM') = ?", month).Select("COALESCE(SUM(amount_paise), 0)").Scan(&subRevenue)
	h.db.Model(&auth.User{}).Select("COALESCE(SUM(unpaid_fine_paise), 0)").Scan(&fineRevenue) // Mock monthly fine logic

	// Expenditures
	h.db.Model(&Expenditure{}).Where("month = ?", month).Select("COALESCE(SUM(amount_paise), 0)").Scan(&totalExp)

	grossRevenue := subRevenue + fineRevenue
	netProfit := grossRevenue - totalExp
	
	margin := 0.0
	if grossRevenue > 0 {
		margin = float64(netProfit) / float64(grossRevenue) * 100
	}

	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"month": month,
		"gross_revenue": gin.H{
			"subscriptions_paise":      subRevenue,
			"cancellation_fines_paise": fineRevenue,
			"total_gross_paise":       grossRevenue,
		},
		"expenditures": gin.H{
			"total_expenditure_paise": totalExp,
		},
		"net_profit_paise":         netProfit,
		"profit_margin_percentage": margin,
	}, nil)
}
