package taxonomy

import (
	"net/http"

	"shiftley/pkg/utils"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	repo Repository
}

func NewHandler(repo Repository) *Handler {
	return &Handler{repo: repo}
}

// GetTaxonomy handles GET /api/v1/taxonomy
// @Summary Get All Categories & Skills
// @Description Returns a fully nested list of all active categories and their child skills.
// @Tags Taxonomy
// @Produce json
// @Success 200 {object} utils.SuccessResponse
// @Router /taxonomy [get]
func (h *Handler) GetTaxonomy(c *gin.Context) {
	categories, err := h.repo.GetTaxonomy(c.Request.Context())
	if err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to fetch taxonomy", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, categories, gin.H{
		"total_categories": len(categories),
	})
}
