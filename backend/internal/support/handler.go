package support

import (
	"net/http"

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

type CreateTicketRequest struct {
	Subject      string     `json:"subject" binding:"required"`
	Description  string     `json:"description" binding:"required"`
	RelatedGigID *uuid.UUID `json:"related_gig_id"`
}

// CreateTicket handles POST /api/v1/support/tickets
// @Summary Raise Customer Support Ticket
// @Description Creates a new support ticket for a user.
// @Tags Support
// @Accept json
// @Produce json
// @Param request body CreateTicketRequest true "Ticket Details"
// @Success 201 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /support/tickets [post]
func (h *Handler) CreateTicket(c *gin.Context) {
	userIDStr, _ := c.Get("userID")
	userID, _ := uuid.Parse(userIDStr.(string))

	var req CreateTicketRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", nil)
		return
	}

	ticket := gig.SupportTicket{
		UserID:      userID,
		GigID:       req.RelatedGigID,
		Subject:     req.Subject,
		Description: req.Description,
		Status:      "OPEN",
	}

	if err := h.db.Create(&ticket).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to create support ticket", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusCreated, ticket, nil)
}
