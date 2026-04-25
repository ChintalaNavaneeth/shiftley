package admin

import (
	"net/http"

	"shiftley/internal/taxonomy"
	"shiftley/pkg/utils"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type TaxonomyHandler struct {
	db *gorm.DB
}

func NewTaxonomyHandler(db *gorm.DB) *TaxonomyHandler {
	return &TaxonomyHandler{db: db}
}

type CreateCategoryRequest struct {
	ID   string `json:"id" binding:"required"`
	Name string `json:"name" binding:"required"`
}

// CreateCategory handles POST /api/v1/admin/taxonomy/categories
// @Summary Create Taxonomy Category
// @Description Adds a new broad job category to the platform.
// @Tags Admin
// @Accept json
// @Produce json
// @Param request body CreateCategoryRequest true "Category Details"
// @Success 201 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /admin/taxonomy/categories [post]
func (h *TaxonomyHandler) CreateCategory(c *gin.Context) {
	var req CreateCategoryRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", nil)
		return
	}

	cat := taxonomy.Category{
		ID:   req.ID,
		Name: req.Name,
	}

	if err := h.db.Create(&cat).Error; err != nil {
		utils.RespondError(c, http.StatusConflict, "ERR_CONFLICT", "Category ID or Name already exists", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusCreated, cat, nil)
}

type CreateSkillRequest struct {
	ID   string `json:"id" binding:"required"`
	Name string `json:"name" binding:"required"`
}

// CreateSkill handles POST /api/v1/admin/taxonomy/categories/{categoryId}/skills
// @Summary Create Taxonomy Skill
// @Description Adds a specific job role under an existing category.
// @Tags Admin
// @Accept json
// @Produce json
// @Param categoryId path string true "Category ID"
// @Param request body CreateSkillRequest true "Skill Details"
// @Success 201 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /admin/taxonomy/categories/{categoryId}/skills [post]
func (h *TaxonomyHandler) CreateSkill(c *gin.Context) {
	catID := c.Param("categoryId")
	var req CreateSkillRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", nil)
		return
	}

	skill := taxonomy.Skill{
		ID:         req.ID,
		CategoryID: catID,
		Name:       req.Name,
	}

	if err := h.db.Create(&skill).Error; err != nil {
		utils.RespondError(c, http.StatusConflict, "ERR_CONFLICT", "Skill ID already exists or Category not found", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusCreated, skill, nil)
}

type ToggleStateRequest struct {
	IsActive bool `json:"is_active"`
}

// ToggleSkillState handles PATCH /api/v1/admin/taxonomy/skills/{id}
// @Summary Toggle Taxonomy State
// @Description Safely disables a skill so it no longer appears in public dropdowns.
// @Tags Admin
// @Accept json
// @Produce json
// @Param id path string true "Skill ID"
// @Param request body ToggleStateRequest true "Toggle State"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /admin/taxonomy/skills/{id} [patch]
func (h *TaxonomyHandler) ToggleSkillState(c *gin.Context) {
	id := c.Param("id")
	var req ToggleStateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", nil)
		return
	}

	if err := h.db.Model(&taxonomy.Skill{}).Where("id = ?", id).Update("is_active", req.IsActive).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to update skill state", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, gin.H{"id": id, "is_active": req.IsActive}, nil)
}
