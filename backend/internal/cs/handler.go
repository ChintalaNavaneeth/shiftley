package cs

import (
	"fmt"
	"net/http"

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

// RecommendResolution handles POST /api/v1/cs/gigs/:gigId/employees/:empId/recommend
func (h *Handler) RecommendResolution(c *gin.Context) {
	gigID, _ := uuid.Parse(c.Param("gigId"))
	empID, _ := uuid.Parse(c.Param("empId"))
	agentIDStr, _ := c.Get("userID")
	agentID, _ := uuid.Parse(agentIDStr.(string))

	var req struct {
		Recommendation string `json:"recommendation" binding:"required"` // REFUND_EMPLOYER, PAY_WORKER
		Reason         string `json:"reason" binding:"required"`
		AmountPaise    int64  `json:"amount_paise" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Recommendation, Reason and Amount required", nil)
		return
	}

	// Create resolution request for Admin approval
	resReq := DisputeResolutionRequest{
		GigID:          gigID,
		EmployeeID:     empID,
		CSAgentID:      agentID,
		Recommendation: req.Recommendation,
		Reason:         req.Reason,
		AmountPaise:    req.AmountPaise,
		Status:         StatusPending,
	}

	if err := h.db.Create(&resReq).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to submit recommendation", nil)
		return
	}

	// Log a note as well
	note := AccountNote{
		UserID:   empID,
		AgentID:  agentID,
		Category: "RESOLUTION_RECOMMENDED",
		Note:     fmt.Sprintf("Recommended %s for Gig %s. Reason: %s", req.Recommendation, gigID, req.Reason),
	}
	h.db.Create(&note)

	utils.RespondSuccess(c, http.StatusOK, resReq, "Recommendation submitted for Admin review")
}
