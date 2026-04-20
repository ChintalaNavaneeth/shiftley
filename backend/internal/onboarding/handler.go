package onboarding

import (
	"net/http"
	"shiftley/pkg/utils"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	// svc Service // To be implemented
}

func NewHandler() *Handler {
	return &Handler{}
}

// OnboardEmployer handles POST /api/v1/onboarding/employer
// @Summary Onboard Employer
// @Description Completes the onboarding process for an employer
// @Tags Onboarding
// @Accept multipart/form-data
// @Produce json
// @Param full_name formData string true "Full Name"
// @Param business_name formData string true "Business Name"
// @Param business_logo formData file false "Business Logo"
// @Success 201 {object} utils.SuccessResponse
// @Failure 400 {object} utils.FailureResponse
// @Security ApiKeyAuth
// @Router /onboarding/employer [post]
func (h *Handler) OnboardEmployer(c *gin.Context) {
	// Multipart form handling logic
	// In a real scenario, we would parse files and store in MinIO
	
	fullName := c.PostForm("full_name")
	businessName := c.PostForm("business_name")
	
	if fullName == "" || businessName == "" {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Missing required fields", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusCreated, gin.H{
		"message": "Employer onboarding successful (Mock)",
		"user": gin.H{
			"business_name": businessName,
			"kyc_status":    "PENDING",
		},
	}, nil)
}

// OnboardEmployee handles POST /api/v1/onboarding/employee
// @Summary Onboard Employee
// @Description Completes the onboarding process for an employee
// @Tags Onboarding
// @Accept multipart/form-data
// @Produce json
// @Param full_name formData string true "Full Name"
// @Param profile_photo formData file false "Profile Photo"
// @Param aadhaar_front formData file true "Aadhaar Front"
// @Param aadhaar_back formData file true "Aadhaar Back"
// @Success 201 {object} utils.SuccessResponse
// @Failure 400 {object} utils.FailureResponse
// @Security ApiKeyAuth
// @Router /onboarding/employee [post]
func (h *Handler) OnboardEmployee(c *gin.Context) {
	fullName := c.PostForm("full_name")
	
	if fullName == "" {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Missing required fields", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusCreated, gin.H{
		"message": "Employee onboarding successful (Mock)",
		"user": gin.H{
			"full_name":  fullName,
			"kyc_status": "PENDING",
		},
	}, nil)
}
