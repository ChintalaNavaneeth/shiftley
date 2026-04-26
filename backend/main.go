package main

import (
	"fmt"
	"log"
	"shiftley/internal/admin"
	"shiftley/internal/analytics"
	"shiftley/internal/auth"
	"shiftley/internal/config"
	"shiftley/internal/cs"
	"shiftley/internal/employee"
	"shiftley/internal/employer"
	"shiftley/internal/gig"
	"shiftley/internal/hr"
	"shiftley/internal/webhook"
	"shiftley/internal/onboarding"
	"shiftley/internal/support"
	"shiftley/internal/taxonomy"
	"shiftley/internal/verifier"
	"shiftley/pkg/middleware"
	"shiftley/pkg/notify"
	"shiftley/pkg/storage"
	"shiftley/pkg/utils"
	"context"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
	_ "shiftley/docs" // This will be the generated docs package
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

// @title Shiftley API
// @version 1.0
// @description Shiftley Backend API Documentation.
// @termsOfService http://swagger.io/terms/

// @contact.name API Support
// @contact.url http://www.shiftley.com/support
// @contact.email support@shiftley.com

// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html

// @host localhost:8080
// @BasePath /api/v1

// @securityDefinitions.apikey ApiKeyAuth
// @in header
// @name Authorization

func main() {
	// 1. Load Config
	cfg := config.LoadConfig()

	// 2. Initialize Database
	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable",
		cfg.DBHost, cfg.DBUser, cfg.DBPassword, cfg.DBName, cfg.DBPort)
	
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	// Auto Migrate Models
	db.Exec("CREATE SCHEMA IF NOT EXISTS shiftley")
	db.AutoMigrate(&auth.User{}, &auth.OTP{}, &auth.KYCSession{}, &taxonomy.Category{}, &taxonomy.Skill{}, &config.PlatformConfig{}, &verifier.VerificationAudit{}, &employer.Subscription{}, &gig.Gig{}, &gig.GigApplication{}, &analytics.Expenditure{}, &cs.AccountNote{})

	// 3. Initialize Redis
	rdb := redis.NewClient(&redis.Options{
		Addr:     fmt.Sprintf("%s:%s", cfg.RedisHost, cfg.RedisPort),
		Password: cfg.RedisPassword,
		DB:       0,
	})

	// 4. Initialize Storage
	storageSvc, err := storage.NewMinioStorage(cfg.MinioEndpoint, cfg.MinioUser, cfg.MinioPassword)
	if err != nil {
		log.Fatalf("Failed to connect to Minio: %v", err)
	}
	
	buckets := []string{cfg.BucketProfiles, cfg.BucketLogos, cfg.BucketKYC}
	for _, b := range buckets {
		if err := storageSvc.EnsureBucketExists(context.Background(), b); err != nil {
			log.Fatalf("Failed to ensure Minio bucket %s exists: %v", b, err)
		}
	}

	// 5. Initialize Notify Service (WhatsApp Business Cloud API)
	notifySvc := notify.NewNotifyService(cfg.WhatsAppPhoneNumberID, cfg.WhatsAppAccessToken)

	// 6. Initialize Handlers & Services
	authRepo := auth.NewRepository(db, rdb)
	authSvc := auth.NewService(authRepo, cfg.JWTSecret)
	authHandler := auth.NewHandler(authSvc, notifySvc, db)

	onboardingHandler := onboarding.NewHandler(storageSvc, cfg.BucketProfiles, cfg.BucketLogos, cfg.BucketKYC, notifySvc)

	adminHandler := admin.NewHandler(db, rdb)
	taxonomyAdminHandler := admin.NewTaxonomyHandler(db)
	employerHandler := employer.NewHandler(db)
	gigHandler := gig.NewHandler(db, notifySvc)
	employeeHandler := employee.NewHandler(db)
	supportHandler := support.NewHandler(db)
	analyticsHandler := analytics.NewHandler(db)
	csHandler := cs.NewHandler(db, notifySvc)
	hrHandler := hr.NewHandler(db, rdb)
	webhookHandler := webhook.NewHandler(db, cfg.RazorpayWebhookSecret, cfg.WhatsAppWebhookSecret)
	
	verifierRepo := verifier.NewRepository(db)
	verifierHandler := verifier.NewHandler(verifierRepo, storageSvc, cfg.BucketKYC, notifySvc)

	taxonomyRepo := taxonomy.NewRepository(db)
	taxonomyHandler := taxonomy.NewHandler(taxonomyRepo)

	// Seed Taxonomy Data
	if err := taxonomyRepo.SeedInitialData(context.Background()); err != nil {
		log.Printf("Warning: Failed to seed taxonomy data: %v", err)
	}

	// 6. Setup Router
	r := gin.Default()

	// Suppress trusted proxies warning
	r.SetTrustedProxies(nil)

	// Health Check
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "healthy", "service": "shiftley-backend"})
	})

	// API v1 Routes
	v1 := r.Group("/api/v1")
	{
		// Swagger Documentation
		v1.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

		// Auth
		authGroup := v1.Group("/auth")
		{
			authGroup.POST("/otp/send", authHandler.SendOTP)
			authGroup.POST("/otp/verify", authHandler.VerifyOTP)
			
			// KYC - Protected by Registration Token (Worker only usually)
			kycGroup := authGroup.Group("/kyc")
			kycGroup.Use(middleware.RequireAuth(cfg.JWTSecret, rdb))
			{
				kycGroup.POST("/aadhaar-xml", authHandler.VerifyAadhaarXML)
			}
		}

		// Onboarding
		onboardingGroup := v1.Group("/onboarding")
		{
			onboardingGroup.POST("/employer", onboardingHandler.OnboardEmployer)
			
			// Employee Onboarding is strictly for SUPER_ADMIN
			onboardingGroup.POST("/employee", 
				middleware.RequireAuth(cfg.JWTSecret, rdb), 
				middleware.RequireRoles(string(auth.RoleSuperAdmin)), 
				onboardingHandler.OnboardEmployee,
			)
		}

		// Taxonomy
		v1.GET("/taxonomy", taxonomyHandler.GetTaxonomy)

		// Admin
		adminGroup := v1.Group("/admin")
		{
			// Global Admin Protection
			adminGroup.Use(middleware.RequireAuth(cfg.JWTSecret, rdb))

			usersGroup := adminGroup.Group("/users")
			// Only SUPER_ADMIN and ADMIN (HR_ADMIN) can invite internal staff
			usersGroup.Use(middleware.RequireRoles(string(auth.RoleSuperAdmin), string(auth.RoleAdmin)))
			{
				usersGroup.POST("/invite", adminHandler.InviteUser)
				usersGroup.PATCH("/:id/status", adminHandler.UpdateUserStatus)
			}

			superGroup := adminGroup.Group("/super")
			superGroup.Use(middleware.RequireRoles(string(auth.RoleSuperAdmin)))
			{
				superGroup.POST("/users", adminHandler.CreateManagementUser)
			}

			// Taxonomy Admin
			taxGroup := adminGroup.Group("/taxonomy")
			taxGroup.Use(middleware.RequireRoles(string(auth.RoleSuperAdmin)))
			{
				taxGroup.POST("/categories", taxonomyAdminHandler.CreateCategory)
				taxGroup.POST("/categories/:categoryId/skills", taxonomyAdminHandler.CreateSkill)
				taxGroup.PATCH("/skills/:id", taxonomyAdminHandler.ToggleSkillState)
			}

			// Platform Config
			adminGroup.PATCH("/config/fees", middleware.RequireRoles(string(auth.RoleSuperAdmin)), adminHandler.UpdatePlatformConfig)
		}

		// Analytics
		analyticsGroup := v1.Group("/analytics")
		analyticsGroup.Use(middleware.RequireAuth(cfg.JWTSecret, rdb))
		{
			// Read-only metrics for Analysts and Super Admins
			analystRoles := []string{string(auth.RoleAnalyst), string(auth.RoleSuperAdmin)}
			analyticsGroup.GET("/overview", middleware.RequireRoles(analystRoles...), analyticsHandler.GetOverview)
			analyticsGroup.GET("/financials", middleware.RequireRoles(analystRoles...), analyticsHandler.GetFinancials)
			analyticsGroup.GET("/liquidity", middleware.RequireRoles(analystRoles...), analyticsHandler.GetLiquidity)
			analyticsGroup.GET("/health", middleware.RequireRoles(analystRoles...), analyticsHandler.GetHealth)
			analyticsGroup.GET("/customer-service", middleware.RequireRoles(analystRoles...), analyticsHandler.GetCustomerServiceStats)

			// Financial inputs and P&L strictly for Super Admin
			analyticsGroup.POST("/expenditure", middleware.RequireRoles(string(auth.RoleSuperAdmin)), analyticsHandler.LogExpenditure)
			analyticsGroup.GET("/pnl", middleware.RequireRoles(string(auth.RoleSuperAdmin)), analyticsHandler.GetPnL)
		}

		// Customer Service (Internal)
		csGroup := v1.Group("/cs")
		csGroup.Use(middleware.RequireAuth(cfg.JWTSecret, rdb), middleware.RequireRoles(string(auth.RoleCSAgent), string(auth.RoleSuperAdmin)))
		{
			csGroup.GET("/users/search", csHandler.SearchUser)
			csGroup.POST("/users/:userId/notes", csHandler.AddNote)
			csGroup.GET("/users/:userId/notes", csHandler.GetNotes)
			csGroup.GET("/gigs/:gigId", csHandler.GetGigDetails)
			csGroup.POST("/gigs/:gigId/employees/:empId/force-release", csHandler.ForceEscrowRelease)
		}

		// HR Admin
		hrGroup := v1.Group("/hr")
		hrGroup.Use(middleware.RequireAuth(cfg.JWTSecret, rdb), middleware.RequireRoles(string(auth.RoleHRAdmin), string(auth.RoleSuperAdmin)))
		{
			hrGroup.POST("/staff", hrHandler.CreateStaff)
			hrGroup.GET("/staff", hrHandler.GetStaffRoster)
			hrGroup.PATCH("/staff/:id/status", hrHandler.UpdateStaffStatus)
		}

		// Webhooks (Internal)
		webhookGroup := v1.Group("/webhooks")
		{
			webhookGroup.POST("/razorpay", webhookHandler.RazorpayWebhook)
			webhookGroup.POST("/whatsapp", webhookHandler.WhatsAppWebhook)
		}

		// Verifier
		verifierGroup := v1.Group("/verifier")
		verifierGroup.Use(middleware.RequireAuth(cfg.JWTSecret, rdb), middleware.RequireRoles(string(auth.RoleVerifier), string(auth.RoleSuperAdmin)))
		{
			verifierGroup.GET("/queue", verifierHandler.GetQueue)
			verifierGroup.POST("/employers/:id/verify", verifierHandler.VerifyEmployer)
			verifierGroup.POST("/employees/:id/verify", verifierHandler.VerifyEmployee)
		}

		// Employer & Gigs
		employerGroup := v1.Group("/employers")
		employerGroup.Use(middleware.RequireAuth(cfg.JWTSecret, rdb), middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)))
		{
			employerGroup.GET("/me", employerHandler.GetProfile)
			employerGroup.GET("/me/gigs", employerHandler.GetMyGigs)
			employerGroup.POST("/me/subscription", employerHandler.PurchaseSubscription)
			employerGroup.GET("/profiles/employees/:empId", employerHandler.GetEmployeeProfile)
		}

		gigGroup := v1.Group("/gigs")
		gigGroup.Use(middleware.RequireAuth(cfg.JWTSecret, rdb))
		{
			gigGroup.GET("/wage-benchmark", gigHandler.GetBenchmark)
			
			// Employer only actions
			gigGroup.POST("", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.PostGig)
			gigGroup.GET("/search", middleware.RequireRoles(string(auth.RoleWorker), string(auth.RoleSuperAdmin)), gigHandler.SearchGigs)
			gigGroup.POST("/:gigId/apply", middleware.RequireRoles(string(auth.RoleWorker), string(auth.RoleSuperAdmin)), gigHandler.ApplyForGig)
			gigGroup.POST("/:gigId/confirm-attendance", middleware.RequireRoles(string(auth.RoleWorker), string(auth.RoleSuperAdmin)), gigHandler.ConfirmAttendance)
			gigGroup.POST("/:gigId/scan-qr", middleware.RequireRoles(string(auth.RoleWorker), string(auth.RoleSuperAdmin)), gigHandler.ScanQR)
			gigGroup.POST("/:gigId/employer-review", middleware.RequireRoles(string(auth.RoleWorker), string(auth.RoleSuperAdmin)), gigHandler.SubmitEmployerReview)
			gigGroup.POST("/:gigId/revoke-application", middleware.RequireRoles(string(auth.RoleWorker), string(auth.RoleSuperAdmin)), gigHandler.RevokeApplication)
			
			gigGroup.GET("/:gigId/applications", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.GetApplications)
			gigGroup.POST("/:gigId/cancel", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.CancelGig)
			gigGroup.POST("/:gigId/close-unfilled", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.CloseUnfilled)
			gigGroup.GET("/:gigId/attendance-qr", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.GenerateQR)
			gigGroup.POST("/:gigId/employees/:empId/mark-arrived", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.MarkArrived)
			gigGroup.POST("/:gigId/employees/:empId/complete", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.CompleteShift)
			gigGroup.POST("/:gigId/emergency-hire", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.EmergencyHire)
			gigGroup.POST("/:gigId/employees/:empId/review", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.SubmitReview)
		}

		appGroup := v1.Group("/applications")
		appGroup.Use(middleware.RequireAuth(cfg.JWTSecret, rdb))
		{
			appGroup.PATCH("/:applicationId/status", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.ApproveApplication)
		}

		employeeGroup := v1.Group("/employees")
		employeeGroup.Use(middleware.RequireAuth(cfg.JWTSecret, rdb), middleware.RequireRoles(string(auth.RoleWorker), string(auth.RoleSuperAdmin)))
		{
			employeeGroup.GET("/me", employeeHandler.GetProfile)
			employeeGroup.GET("/me/schedule", employeeHandler.GetSchedule)
			employeeGroup.PUT("/me/payout-methods", employeeHandler.UpdatePayoutMethods)
			employeeGroup.POST("/me/pay-penalty", employeeHandler.PayPenalty)
		}


		supportGroup := v1.Group("/support")
		supportGroup.Use(middleware.RequireAuth(cfg.JWTSecret, rdb))
		{
			supportGroup.POST("/tickets", supportHandler.CreateTicket)
		}
	}

	fmt.Printf("Shiftley Backend starting on :%s...\n", cfg.AppPort)
	if err := r.Run(":" + cfg.AppPort); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
