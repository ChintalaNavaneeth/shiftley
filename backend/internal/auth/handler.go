package auth

import (
	"fmt"
	"net/http"
	"strings"
	"time"

	"shiftley/pkg/notify"
	"shiftley/pkg/utils"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Handler struct {
	svc    Service
	notify *notify.NotifyService
	db     *gorm.DB
}

func NewHandler(svc Service, notifySvc *notify.NotifyService, db *gorm.DB) *Handler {
	return &Handler{svc: svc, notify: notifySvc, db: db}
}

type SendOTPRequest struct {
	Identifier string `json:"identifier" form:"identifier" binding:"required"`
	Type       string `json:"type" form:"type" binding:"required,oneof=PHONE EMAIL"`
	Role       string `json:"role" form:"role" binding:"required,oneof=WORKER EMPLOYER VERIFIER CS_AGENT ANALYST ADMIN HR_ADMIN SUPER_ADMIN"`
}

// SendOTP handles POST /api/v1/auth/otp/send
// @Summary Request OTP
// @Description Sends a 6-digit OTP to the user's phone or email
// @Tags Auth
// @Accept x-www-form-urlencoded
// @Produce json
// @Param identifier formData string true "Identifier (Phone or Email)"
// @Param type formData string true "Type" Enums(PHONE, EMAIL)
// @Param role formData string true "Role" Enums(WORKER, EMPLOYER)
// @Success 200 {object} utils.SuccessResponse
// @Failure 400 {object} utils.FailureResponse
// @Failure 500 {object} utils.FailureResponse
// @Router /auth/otp/send [post]
func (h *Handler) SendOTP(c *gin.Context) {
	var req SendOTPRequest
	if err := c.ShouldBind(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", []string{err.Error()})
		return
	}

	code, err := h.svc.SendOTP(c.Request.Context(), req.Identifier, req.Type, req.Role)
	if err != nil {
		if strings.Contains(err.Error(), "unauthorized") {
			utils.RespondError(c, http.StatusForbidden, utils.ErrForbidden, err.Error(), nil)
			return
		}
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to send OTP", []string{err.Error()})
		return
	}

	// Dual-Channel Delivery Logic
	var user User
	if err := h.db.Where("email = ? OR phone_number = ?", req.Identifier, req.Identifier).First(&user).Error; err == nil {
		// 1. Send to Phone (WhatsApp)
		if user.PhoneNumber != "" {
			h.notify.SendOTP(user.PhoneNumber, code)
		}
		// 2. Send to Email (Mocked for now)
		if user.Email != "" {
			fmt.Printf("[MOCK EMAIL OTP] Sent %s to %s (Dual-Channel)\n", code, user.Email)
		}
	} else {
		// New User Flow: Just send to the provided identifier
		h.notify.SendOTP(req.Identifier, code)
	}

	utils.RespondSuccess(c, http.StatusOK, "OTP sent successfully to your registered contact methods", nil)
}

type VerifyOTPRequest struct {
	Identifier string `json:"identifier" form:"identifier" binding:"required"`
	Type       string `json:"type" form:"type" binding:"required,oneof=PHONE EMAIL"`
	Code       string `json:"code" form:"code" binding:"required,len=6"`
	Role       string `json:"role" form:"role" binding:"omitempty"`
}

// VerifyOTP handles POST /api/v1/auth/otp/verify
// @Summary Verify OTP
// @Description Verifies the OTP and returns a JWT token
// @Tags Auth
// @Accept x-www-form-urlencoded
// @Produce json
// @Param identifier formData string true "Identifier (Phone or Email)"
// @Param type formData string true "Type" Enums(PHONE, EMAIL)
// @Param code formData string true "6-digit OTP"
// @Success 200 {object} utils.SuccessResponse
// @Failure 400 {object} utils.FailureResponse
// @Router /auth/otp/verify [post]
func (h *Handler) VerifyOTP(c *gin.Context) {
	var req VerifyOTPRequest
	if err := c.ShouldBind(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid request payload", []string{err.Error()})
		return
	}

	accessToken, refreshToken, isNewUser, user, err := h.svc.VerifyOTP(c.Request.Context(), req.Identifier, req.Type, req.Code, req.Role)
	if err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, err.Error(), nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"is_new_user":               isNewUser,
		"access_token":              accessToken,
		"registration_token":        accessToken,
		"refresh_token":             refreshToken,
		"is_initial_setup_complete": user.IsInitialSetupComplete,
		"user": gin.H{
			"id":          user.ID,
			"role":        user.Role,
			"is_verified": user.IsVerified,
		},
	}, nil)
}

type RefreshTokenRequest struct {
	RefreshToken string `json:"refresh_token" form:"refresh_token" binding:"required"`
}

// RefreshToken handles POST /api/v1/auth/token/refresh
// @Summary Refresh Access Token
// @Description Uses a refresh token to get a new access/refresh token pair
// @Tags Auth
// @Accept json
// @Accept x-www-form-urlencoded
// @Produce json
// @Param refresh_token formData string true "Refresh Token"
// @Success 200 {object} utils.SuccessResponse
// @Failure 401 {object} utils.FailureResponse
// @Router /auth/token/refresh [post]
func (h *Handler) RefreshToken(c *gin.Context) {
	var req RefreshTokenRequest
	// Try binding from both JSON and Form (for flexibility)
	if err := c.ShouldBind(&req); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Refresh token is required", []string{err.Error()})
		return
	}

	newAccessToken, newRefreshToken, err := h.svc.RefreshToken(c.Request.Context(), req.RefreshToken)
	if err != nil {
		utils.RespondError(c, http.StatusUnauthorized, utils.ErrUnauthorized, err.Error(), nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"access_token":  newAccessToken,
		"refresh_token": newRefreshToken,
	}, nil)
}

// VerifyAadhaarXML handles POST /api/v1/auth/kyc/aadhaar-xml
func (h *Handler) VerifyAadhaarXML(c *gin.Context) {
	userIDVal, exists := c.Get("userID")
	if !exists {
		utils.RespondError(c, http.StatusUnauthorized, utils.ErrUnauthorized, "User session not found", nil)
		return
	}
	userIDStr, ok := userIDVal.(string)
	if !ok {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Invalid session data", nil)
		return
	}
	userID, _ := uuid.Parse(userIDStr)

	shareCode := c.PostForm("share_code")
	file, err := c.FormFile("xml_file")
	if err != nil || shareCode == "" {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "XML file and share code are required", nil)
		return
	}

	// 1. Process File (Simplified: assuming extracted XML or standard Zip)
	// In production, use github.com/alexmullins/zip for password-protected zips
	f, _ := file.Open()
	defer f.Close()

	// Mock data extraction (simulate XML parsing)
	// Normal flow: Read XML -> Decrypt with share code -> Verify UIDAI Signature -> Extract
	fmt.Printf("[MOCK Aadhaar KYC] Verifying XML for user %s with share code %s\n", userID, shareCode)

	// Simulation of extracted data
	extractedName := "Verified User"
	maskedAadhaar := "XXXX XXXX 1234"

	// 2. Update KYC Session
	now := time.Now()
	kyc := &KYCSession{
		UserID:        userID,
		Provider:      "OFFLINE_XML",
		Status:        "VERIFIED",
		MaskedAadhaar: maskedAadhaar,
		VerifiedAt:    &now,
	}

	if err := h.db.Where("user_id = ?", userID).Assign(kyc).FirstOrCreate(&kyc).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to save KYC results", nil)
		return
	}

	// 3. Update User Status
	if err := h.db.Model(&User{}).Where("id = ?", userID).Updates(map[string]interface{}{
		"is_verified": true,
		"full_name":   extractedName,
	}).Error; err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to update user status", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, gin.H{
		"name":           extractedName,
		"masked_aadhaar": maskedAadhaar,
		"status":         "VERIFIED",
	}, nil)
}

// Logout handles POST /api/v1/auth/logout
// @Summary Logout User
// @Description Invalidates the current session token by blacklisting the user in Redis.
// @Tags Auth
// @Produce json
// @Success 200 {object} utils.SuccessResponse
// @Security ApiKeyAuth
// @Router /auth/logout [post]
func (h *Handler) Logout(c *gin.Context) {
	userIDStr, exists := c.Get("userID")
	if !exists {
		utils.RespondError(c, http.StatusUnauthorized, utils.ErrUnauthorized, "User session not found", nil)
		return
	}

	err := h.svc.Logout(c.Request.Context(), userIDStr.(string))
	if err != nil {
		utils.RespondError(c, http.StatusInternalServerError, utils.ErrInternal, "Failed to logout", nil)
		return
	}

	utils.RespondSuccess(c, http.StatusOK, "Logged out successfully", nil)
}

// GetMe handles GET /api/v1/auth/me
func (h *Handler) GetMe(c *gin.Context) {
	userIDVal, _ := c.Get("userID")
	userIDStr := userIDVal.(string)

	var user User
	if err := h.db.First(&user, "id = ?", userIDStr).Error; err != nil {
		utils.RespondError(c, http.StatusNotFound, utils.ErrNotFound, "User not found", nil)
		return
	}

	photoURL := user.ProfilePhotoURL
	if photoURL == "" {
		// Fallback to role-specific profile
		switch user.Role {
		case "WORKER":
			var wp WorkerProfile
			if err := h.db.First(&wp, "user_id = ?", user.ID).Error; err == nil {
				photoURL = wp.ProfilePhotoURL
			}
		case "VERIFIER":
			// Need to import verifier package or use raw SQL/table name since it's in a different package
			var profile struct {
				ProfilePhotoURL string `gorm:"column:profile_photo_url"`
			}
			if err := h.db.Table("shiftley.verifier_profiles").Select("profile_photo_url").Where("user_id = ?", user.ID).First(&profile).Error; err == nil {
				photoURL = profile.ProfilePhotoURL
			}
		}
	}

	// Prepare response
	resp := gin.H{
		"id":                user.ID,
		"full_name":         user.FullName,
		"email":             user.Email,
		"phone_number":      user.PhoneNumber,
		"role":              user.Role,
		"profile_photo_url": photoURL,
		"kyc_status":        user.IsVerified,
	}

	// Add worker specific fields if role is WORKER
	if user.Role == RoleWorker {
		var wp WorkerProfile
		if err := h.db.First(&wp, "user_id = ?", user.ID).Error; err == nil {
			resp["reliability_score"] = wp.ReliabilityScore
			
			// Resolve skill names from IDs
			if len(wp.Skills) > 0 {
				var skillNames []string
				err := h.db.Table("shiftley.skills").
					Where("id::text IN ?", []string(wp.Skills)).
					Pluck("name", &skillNames).Error
				if err != nil {
					fmt.Printf("[DEBUG] Skill resolution error: %v\n", err)
				}
				resp["skills"] = skillNames
				fmt.Printf("[DEBUG] Resolved skills for user %s: %v\n", user.ID, skillNames)
			} else {
				resp["skills"] = []string{}
			}
		} else {
			fmt.Printf("[DEBUG] Worker profile not found for user %s: %v\n", user.ID, err)
		}
	}

	utils.RespondSuccess(c, http.StatusOK, resp, nil)
}

