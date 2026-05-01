package tests

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"shiftley/internal/admin"
	"shiftley/internal/auth"
	"shiftley/internal/config"
	"shiftley/internal/onboarding"
	"shiftley/pkg/middleware"
	"shiftley/pkg/notify"
	"shiftley/pkg/storage"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/alicebob/miniredis/v2"
	"github.com/redis/go-redis/v9"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var (
	testDB     *gorm.DB
	testRDB    *redis.Client
	testRouter *gin.Engine
	jwtSecret  = "test_secret"
)

func setupTest() {
	// Setup SQLite in-memory
	db, _ := gorm.Open(sqlite.Open("file::memory:?cache=shared"), &gorm.Config{})
	testDB = db
	db.AutoMigrate(&auth.User{}, &auth.OTP{}, &auth.KYCSession{}, &auth.WorkerProfile{}, &auth.EmployerProfile{})

	// Setup MiniRedis
	mr, _ := miniredis.Run()
	testRDB = redis.NewClient(&redis.Options{Addr: mr.Addr()})

	// Setup Router
	gin.SetMode(gin.TestMode)
	r := gin.Default()

	// Mock Services
	notifySvc := notify.NewNotifyService("", "")
	storageSvc, _ := storage.NewMinioStorage("localhost:9000", "minio", "minio123") // Mocked anyway

	authRepo := auth.NewRepository(db, testRDB)
	authSvc := auth.NewService(authRepo, jwtSecret)
	authHandler := auth.NewHandler(authSvc, notifySvc, db)

	onboardingHandler := onboarding.NewHandler(db, storageSvc, "profiles", "logos", "kyc", notifySvc)
	adminHandler := admin.NewHandler(db, testRDB)

	v1 := r.Group("/api/v1")
	{
		authGroup := v1.Group("/auth")
		{
			authGroup.POST("/otp/send", authHandler.SendOTP)
			authGroup.POST("/otp/verify", authHandler.VerifyOTP)
		}

		onboardingGroup := v1.Group("/onboarding")
		onboardingGroup.Use(middleware.RequireAuth(jwtSecret, testRDB), middleware.RequireTokenType("registration"))
		{
			onboardingGroup.POST("/employer", onboardingHandler.OnboardEmployer)
			onboardingGroup.POST("/employee", onboardingHandler.OnboardEmployee)
		}

		adminGroup := v1.Group("/admin")
		adminGroup.Use(middleware.RequireAuth(jwtSecret, testRDB), middleware.RequireTokenType("session"))
		{
			adminGroup.POST("/users/invite", middleware.RequireRoles(string(auth.RoleSuperAdmin)), adminHandler.InviteUser)
			adminGroup.PATCH("/super/setup", middleware.RequireRoles(string(auth.RoleSuperAdmin)), adminHandler.UpdateSuperAdminSetup)
		}
	}

	testRouter = r
}

func TestAuthFlows(t *testing.T) {
	os.Setenv("FIXED_OTP", "123456")
	setupTest()

	t.Run("Super Admin Setup Flow", func(t *testing.T) {
		// 1. Seed root admin
		root := &auth.User{
			PhoneNumber: "+910000000000",
			Email:       "root@shiftley.in",
			FullName:    "Root Admin",
			Role:        auth.RoleSuperAdmin,
			IsVerified:  true,
		}
		testDB.Create(root)

		// 2. Request OTP
		w := httptest.NewRecorder()
		reqBody := map[string]string{
			"identifier": "+910000000000",
			"type":       "PHONE",
			"role":       "SUPER_ADMIN",
		}
		body, _ := json.Marshal(reqBody)
		req, _ := http.NewRequest("POST", "/api/v1/auth/otp/send", bytes.NewBuffer(body))
		req.Header.Set("Content-Type", "application/json")
		testRouter.ServeHTTP(w, req)
		assert.Equal(t, http.StatusOK, w.Code)

		// 3. Verify OTP
		w = httptest.NewRecorder()
		reqBody = map[string]string{
			"identifier": "+910000000000",
			"type":       "PHONE",
			"code":       "123456",
		}
		body, _ = json.Marshal(reqBody)
		req, _ = http.NewRequest("POST", "/api/v1/auth/otp/verify", bytes.NewBuffer(body))
		req.Header.Set("Content-Type", "application/json")
		testRouter.ServeHTTP(w, req)
		assert.Equal(t, http.StatusOK, w.Code)

		var resp map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &resp)
		data := resp["data"].(map[string]interface{})
		sessionToken := data["session_token"].(string)

		// 4. Update Setup
		w = httptest.NewRecorder()
		setupReq := map[string]string{
			"full_name":    "Navaneeth Chintala",
			"email":        "navaneeth@shiftley.in",
			"phone_number": "+919876543210",
		}
		body, _ = json.Marshal(setupReq)
		req, _ = http.NewRequest("PATCH", "/api/v1/admin/super/setup", bytes.NewBuffer(body))
		req.Header.Set("Authorization", "Bearer "+sessionToken)
		req.Header.Set("Content-Type", "application/json")
		testRouter.ServeHTTP(w, req)
		assert.Equal(t, http.StatusOK, w.Code)
	})

	t.Run("Employer Registration & Login", func(t *testing.T) {
		phone := "+918888888888"
		
		// 1. Request OTP
		w := httptest.NewRecorder()
		reqBody := map[string]string{
			"identifier": phone,
			"type":       "PHONE",
			"role":       "EMPLOYER",
		}
		body, _ := json.Marshal(reqBody)
		req, _ := http.NewRequest("POST", "/api/v1/auth/otp/send", bytes.NewBuffer(body))
		req.Header.Set("Content-Type", "application/json")
		testRouter.ServeHTTP(w, req)
		assert.Equal(t, http.StatusOK, w.Code)

		// 2. Verify OTP -> Get Registration Token
		w = httptest.NewRecorder()
		reqBody = map[string]string{
			"identifier": phone,
			"type":       "PHONE",
			"code":       "123456",
		}
		body, _ = json.Marshal(reqBody)
		req, _ = http.NewRequest("POST", "/api/v1/auth/otp/verify", bytes.NewBuffer(body))
		req.Header.Set("Content-Type", "application/json")
		testRouter.ServeHTTP(w, req)
		
		var resp map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &resp)
		data := resp["data"].(map[string]interface{})
		regToken := data["registration_token"].(string)

		// 3. Onboarding (Simplified for test - mock the multipart)
		// Note: The real onboarding expects files, but for the sake of logic testing, 
		// we might need to mock the storage or handle multipart.
		// For now, let's just check if it hits the handler and fails on missing files.
		w = httptest.NewRecorder()
		req, _ = http.NewRequest("POST", "/api/v1/onboarding/employer", nil)
		req.Header.Set("Authorization", "Bearer "+regToken)
		testRouter.ServeHTTP(w, req)
		// Should be 400 because of missing fields/files
		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("Admin Invites Verifier", func(t *testing.T) {
		// Get Super Admin Token
		var user auth.User
		testDB.First(&user, "phone_number = ?", "+919876543210")
		
		// Generate manual token for admin
		token := auth.GenerateTestToken(user.ID, auth.RoleSuperAdmin, "session", jwtSecret)

		w := httptest.NewRecorder()
		inviteReq := map[string]string{
			"full_name":      "Verifier One",
			"email":          "v1@shiftley.in",
			"phone_number":   "+917777777777",
			"aadhaar_number": "123456789012",
			"role":           "VERIFIER",
		}
		body, _ := json.Marshal(inviteReq)
		req, _ := http.NewRequest("POST", "/api/v1/admin/users/invite", bytes.NewBuffer(body))
		req.Header.Set("Authorization", "Bearer "+token)
		req.Header.Set("Content-Type", "application/json")
		testRouter.ServeHTTP(w, req)
		assert.Equal(t, http.StatusCreated, w.Code)
	})
}
