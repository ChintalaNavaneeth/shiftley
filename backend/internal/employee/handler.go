package employee

import (
	"fmt"
	"net/http"

	"shiftley/internal/auth"
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

// PayFine handles POST /api/v1/employees/me/pay-fine
// @Summary Pay Unpaid Fines
// @Description Clears the user's debt (Mock Payment).
// @Tags Employee
// @Produce json
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /employees/me/pay-fine [post]
func (h *Handler) PayFine(c *gin.Context) {
	userIDStr, _ := c.Get("userID")
	userID, _ := uuid.Parse(userIDStr.(string))

	var user auth.User
	if err := h.db.First(&user, userID).Error; err != nil {
		utils.RespondError(c, http.StatusNotFound, utils.ErrNotFound, "User not found", nil)
		return
	}

	if user.UnpaidFinePaise == 0 {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "No unpaid fines found", nil)
		return
	}

	fineAmount := user.UnpaidFinePaise
	user.UnpaidFinePaise = 0
	if err := h.db.Save(&user).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to clear fine", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"message":        fmt.Sprintf("Fine of ₹%.2f cleared successfully. Your account is now unlocked.", float64(fineAmount)/100.0),
		"amount_cleared": fineAmount,
	}, nil)
}
