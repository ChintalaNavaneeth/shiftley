package admin

import (
	"net/http"

	"shiftley/internal/taxonomy"
	"shiftley/pkg/utils"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type TaxonomyHandler struct {
	db *gorm.DB
}

func NewTaxonomyHandler(db *gorm.DB) *TaxonomyHandler {
	return &TaxonomyHandler{db: db}
}

type CreateCategoryRequest struct {
	Name string `json:"name" binding:"required"`
}

type UpdateTaxonomyRequest struct {
	Name     *string `json:"name"`
	IsActive *bool   `json:"is_active"`
}

// GetAdminTaxonomy handles GET /api/v1/admin/taxonomy/categories
// @Summary Get All Taxonomy (Admin)
// @Description Returns all categories and skills, including inactive ones.
// @Tags Admin
// @Produce json
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /admin/taxonomy/categories [get]
func (h *TaxonomyHandler) GetAdminTaxonomy(c *gin.Context) {
	var categories []taxonomy.Category
	if err := h.db.Preload("Skills").Find(&categories).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to fetch taxonomy", nil)
		return
	}
	utils.RespondSuccess(c, http.StatusOK, categories, nil)
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
		Name: req.Name,
	}

	if err := h.db.Create(&cat).Error; err != nil {
		utils.RespondError(c, http.StatusConflict, "ERR_CONFLICT", "Category ID or Name already exists", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusCreated, cat, nil)
}

// UpdateCategory handles PATCH /api/v1/admin/taxonomy/categories/:id
// @Summary Update Taxonomy Category
// @Description Updates name or active state of a category.
// @Tags Admin
// @Accept json
// @Produce json
// @Param id path string true "Category ID"
// @Param request body UpdateTaxonomyRequest true "Update Details"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /admin/taxonomy/categories/{id} [patch]
func (h *TaxonomyHandler) UpdateCategory(c *gin.Context) {
	id := c.Param("id")
	var req UpdateTaxonomyRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", nil)
		return
	}

	updates := make(map[string]interface{})
	if req.Name != nil {
		updates["name"] = *req.Name
	}
	if req.IsActive != nil {
		updates["is_active"] = *req.IsActive
	}

	if err := h.db.Transaction(func(tx *gorm.DB) error {
		// 1. Update the category
		if err := tx.Model(&taxonomy.Category{}).Where("id = ?", id).Updates(updates).Error; err != nil {
			return err
		}

		// 2. If category is being disabled, cascade to all its skills
		if isActive, ok := updates["is_active"].(bool); ok && !isActive {
			if err := tx.Model(&taxonomy.Skill{}).Where("category_id = ?", id).Update("is_active", false).Error; err != nil {
				return err
			}
		}
		return nil
	}); err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to update category with cascade", nil)
		return
	}

	var updatedCat taxonomy.Category
	if err := h.db.Preload("Skills").First(&updatedCat, "id = ?", id).Error; err != nil {
		utils.RespondError(c, http.StatusNotFound, utils.ErrNotFound, "Category not found", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, updatedCat, nil)
}

type CreateSkillRequest struct {
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

	catUUID, err := uuid.Parse(catID)
	if err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid category ID format", nil)
		return
	}

	skill := taxonomy.Skill{
		CategoryID: catUUID,
		Name:       req.Name,
	}

	if err := h.db.Create(&skill).Error; err != nil {
		utils.RespondError(c, http.StatusConflict, "ERR_CONFLICT", "Skill ID already exists or Category not found", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusCreated, skill, nil)
}

// UpdateSkill handles PATCH /api/v1/admin/taxonomy/skills/:id
// @Summary Update Taxonomy Skill
// @Description Updates name or active state of a skill.
// @Tags Admin
// @Accept json
// @Produce json
// @Param id path string true "Skill ID"
// @Param request body UpdateTaxonomyRequest true "Update Details"
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /admin/taxonomy/skills/{id} [patch]
func (h *TaxonomyHandler) UpdateSkill(c *gin.Context) {
	id := c.Param("id")
	var req UpdateTaxonomyRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", nil)
		return
	}

	updates := make(map[string]interface{})
	if req.Name != nil {
		updates["name"] = *req.Name
	}
	if req.IsActive != nil {
		updates["is_active"] = *req.IsActive
	}

	if err := h.db.Model(&taxonomy.Skill{}).Where("id = ?", id).Updates(updates).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to update skill", nil)
		return
	}

	var updatedSkill taxonomy.Skill
	if err := h.db.First(&updatedSkill, "id = ?", id).Error; err != nil {
		utils.RespondError(c, http.StatusNotFound, utils.ErrNotFound, "Skill not found", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, updatedSkill, nil)
}
