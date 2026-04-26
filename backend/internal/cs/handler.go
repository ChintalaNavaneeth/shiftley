package cs

import (
	"fmt"
	"net/http"
	"time"

	"shiftley/internal/auth"
	"shiftley/internal/gig"
	"shiftley/pkg/notify"
	"shiftley/pkg/utils"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Handler struct {
	db     *gorm.DB
	notify *notify.NotifyService
}

func NewHandler(db *gorm.DB, notifySvc *notify.NotifyService) *Handler {
	return &Handler{db: db, notify: notifySvc}
}

// SearchUser handles GET /api/v1/cs/users/search
func (h *Handler) SearchUser(c *gin.Context) {
	phone := c.Query("phone")
	id := c.Query("id")

	var user auth.User
	query := h.db.Model(&auth.User{})
	if id != "" {
		query = query.Where("id = ?", id)
	} else if phone != "" {
		query = query.Where("phone_number = ?", phone)
	} else {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Phone or ID required", nil)
		return
	}

	if err := query.First(&user).Error; err != nil {
		utils.RespondError(c, http.StatusNotFound, utils.ErrNotFound, "User not found", nil)
		return
	}

	// Aggregate history (Simple overview)
	var gigCount int64
	h.db.Model(&gig.GigApplication{}).Where("employee_id = ? AND status = ?", user.ID, gig.AppApproved).Count(&gigCount)

	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"user":           user,
		"confirmed_gigs": gigCount,
	}, nil)
}

// AddNote handles POST /api/v1/cs/users/:userId/notes
func (h *Handler) AddNote(c *gin.Context) {
	userID, _ := uuid.Parse(c.Param("userId"))
	agentIDStr, _ := c.Get("userID")
	agentID, _ := uuid.Parse(agentIDStr.(string))

	var req struct {
		Category string `json:"category" binding:"required"`
		Note     string `json:"note" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid input", nil)
		return
	}

	note := AccountNote{
		UserID:   userID,
		AgentID:  agentID,
		Category: req.Category,
		Note:     req.Note,
	}

	if err := h.db.Create(&note).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to add note", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, note, nil)
}

// GetNotes handles GET /api/v1/cs/users/:userId/notes
func (h *Handler) GetNotes(c *gin.Context) {
	userID, _ := uuid.Parse(c.Param("userId"))

	var notes []AccountNote
	if err := h.db.Where("user_id = ?", userID).Order("created_at DESC").Find(&notes).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to fetch notes", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, notes, nil)
}

// GetGigDetails handles GET /api/v1/cs/gigs/:gigId
func (h *Handler) GetGigDetails(c *gin.Context) {
	gigID := c.Param("gigId")

	var g gig.Gig
	if err := h.db.Preload("Employer").First(&g, "id = ?", gigID).Error; err != nil {
		utils.RespondError(c, http.StatusNotFound, utils.ErrNotFound, "Gig not found", nil)
		return
	}

	var apps []gig.GigApplication
	h.db.Preload("Employee").Where("gig_id = ?", gigID).Find(&apps)

	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"gig":          g,
		"applications": apps,
	}, nil)
}

// ForceEscrowRelease handles POST /api/v1/cs/gigs/:gigId/employees/:empId/force-release
func (h *Handler) ForceEscrowRelease(c *gin.Context) {
	gigID := c.Param("gigId")
	empID := c.Param("empId")
	agentIDStr, _ := c.Get("userID")
	agentID, _ := uuid.Parse(agentIDStr.(string))

	var req struct {
		Reason      string `json:"reason" binding:"required"`
		AmountPaise int64  `json:"amount_paise" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Reason and Amount required", nil)
		return
	}

	// 1. Audit check: > ₹5,000 requires Super Admin (Mock role check)
	userRole, _ := c.Get("role")
	if req.AmountPaise > 500000 && userRole != string(auth.RoleSuperAdmin) {
		utils.RespondError(c, http.StatusForbidden, utils.ErrForbidden, "Amounts > ₹5,000 require Super Admin approval", nil)
		return
	}

	// 2. Process Release (Mock)
	fmt.Printf("[CS FORCE RELEASE] Agent %s released %d paise for Gig %s Employee %s. Reason: %s\n", agentID, req.AmountPaise, gigID, empID, req.Reason)

	// 3. Log Note
	note := AccountNote{
		UserID:   uuid.MustParse(empID),
		AgentID:  agentID,
		Category: "FORCE_RELEASE",
		Note:     fmt.Sprintf("Force Release triggered for Gig %s. Reason: %s", gigID, req.Reason),
	}
	h.db.Create(&note)

	// 4. Notify Worker
	var worker auth.User
	if err := h.db.First(&worker, "id = ?", empID).Error; err == nil {
		var gData gig.Gig
		h.db.First(&gData, "id = ?", gigID)
		h.notify.SendPaymentReleased(worker.PhoneNumber, worker.FullName, fmt.Sprintf("%.2f", float64(req.AmountPaise)/100.0), gData.Title)
	}

	utils.RespondSuccess(c, http.StatusOK, "Escrow payout triggered successfully", nil)
}
