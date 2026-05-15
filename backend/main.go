package main

import (
	"fmt"
	"log"
	"time"
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
	"shiftley/internal/worker"
	"shiftley/pkg/middleware"
	"shiftley/pkg/notify"
	"shiftley/pkg/storage"
	"shiftley/pkg/events"
	"context"
	"strings"

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
	var db *gorm.DB
	var err error
	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable search_path=shiftley,public",
		cfg.DBHost, cfg.DBUser, cfg.DBPassword, cfg.DBName, cfg.DBPort)

	for i := 0; i < 10; i++ {
		db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
			Logger: logger.Default.LogMode(logger.Info),
		})
		if err == nil {
			break
		}
		fmt.Printf("Failed to connect to database (attempt %d): %v\n", i+1, err)
		time.Sleep(2 * time.Second)
	}
	if err != nil {
		log.Fatalf("Failed to connect to database after retries: %v", err)
	}

	// Auto Migrate Models
	fmt.Println("Initializing database schema and migrations...")
	if err := db.Exec("CREATE SCHEMA IF NOT EXISTS shiftley").Error; err != nil {
		log.Fatalf("Failed to create schema: %v", err)
	}
	if err := db.Exec("CREATE EXTENSION IF NOT EXISTS postgis").Error; err != nil {
		log.Fatalf("Failed to create postgis extension: %v", err)
	}

	err = db.AutoMigrate(
		&auth.User{}, &auth.OTP{}, &auth.KYCSession{}, &auth.WorkerProfile{}, &auth.EmployerProfile{}, &auth.Certification{},
		&taxonomy.Category{}, &taxonomy.Skill{},
		&config.PlatformConfig{},
		&verifier.VerificationAudit{}, &verifier.VerifierProfile{},
		&employer.Subscription{}, &employer.SubscriptionPlanMeta{},
		&gig.Gig{}, &gig.GigApplication{}, &gig.GigAttendance{}, &gig.GigReview{}, &gig.SupportTicket{},
		&analytics.Expenditure{},
		&cs.AccountNote{}, &cs.DisputeResolutionRequest{},
	)
	if err != nil {
		log.Fatalf("Database migration failed: %v", err)
	}
	fmt.Println("Database migrations completed successfully.")

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

	// 5.1 Initialize Event Bus
	bus := events.NewMemoryEventBus()

	// 6. Initialize Handlers & Services
	authRepo := auth.NewRepository(db, rdb)
	authSvc := auth.NewService(authRepo, cfg.JWTSecret)
	authHandler := auth.NewHandler(authSvc, notifySvc, db)

	onboardingHandler := onboarding.NewHandler(db, storageSvc, cfg.BucketProfiles, cfg.BucketLogos, cfg.BucketKYC, notifySvc, authSvc)

	adminHandler := admin.NewHandler(db, rdb)
	taxonomyAdminHandler := admin.NewTaxonomyHandler(db)
	employerHandler := employer.NewHandler(db)
	
	// Register Gig Listeners
	gig.RegisterListeners(bus, db, notifySvc)
	
	gigHandler := gig.NewHandler(db, rdb, notifySvc, bus, authSvc)
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

	// 7. Start Background Workers
	subscriptionWorker := worker.NewSubscriptionWorker(db)
	subscriptionWorker.Start()

	// Seed Taxonomy Data
	if err := taxonomyRepo.SeedInitialData(context.Background()); err != nil {
		log.Printf("Warning: Failed to seed taxonomy data: %v", err)
	}

	// Seed Subscription Plans
	var planCount int64
	db.Model(&employer.SubscriptionPlanMeta{}).Count(&planCount)
	if planCount == 0 {
		plans := []employer.SubscriptionPlanMeta{
			{ID: "daily_access", Name: "Daily Plan", PricePaise: 49900, DurationDay: 1, MaxGigs: 3, MaxEmployeesPerGig: 10, IsActive: true},
			{ID: "weekly_unlimited", Name: "Weekly Plan", PricePaise: 199900, DurationDay: 7, MaxGigs: 25, MaxEmployeesPerGig: 12, IsActive: true},
			{ID: "monthly_unlimited", Name: "Monthly Plan", PricePaise: 499900, DurationDay: 30, MaxGigs: 50, MaxEmployeesPerGig: 15, IsActive: true},
		}
		db.Create(&plans)
	}

	// Seed Default Super Admin
	seedDefaultSuperAdmin(db)

	// 6. Setup Router
	r := gin.Default()

	// CORS Middleware
	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, PATCH, DELETE")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	})

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
			authGroup.POST("/token/refresh", authHandler.RefreshToken)

			// Role-Specific Flows (Separated)
			adminAuth := authGroup.Group("/admin")
			{
				adminAuth.POST("/otp/send", authHandler.AdminSendOTP)
				adminAuth.POST("/otp/verify", authHandler.AdminVerifyOTP)
			}

			employerAuth := authGroup.Group("/employer")
			{
				employerAuth.POST("/otp/send", authHandler.EmployerSendOTP)
				employerAuth.POST("/otp/verify", authHandler.EmployerVerifyOTP)
			}

			verifierAuth := authGroup.Group("/verifier")
			{
				verifierAuth.POST("/otp/send", authHandler.VerifierSendOTP)
				verifierAuth.POST("/otp/verify", authHandler.VerifierVerifyOTP)
			}
			
			// KYC - Protected by Registration Token (Worker only usually)
			kycGroup := authGroup.Group("/kyc")
			kycGroup.Use(middleware.RequireAuth(cfg.JWTSecret, rdb), middleware.RequireTokenType("registration"))
			{
				kycGroup.POST("/aadhaar-xml", authHandler.VerifyAadhaarXML)
			}

			// Protected Auth Actions
			protectedAuth := authGroup.Group("")
			protectedAuth.Use(middleware.RequireAuth(cfg.JWTSecret, rdb), middleware.RequireTokenType("session"))
			{
				protectedAuth.GET("/me", authHandler.GetMe)
				protectedAuth.POST("/logout", authHandler.Logout)
			}
		}

		// Onboarding - Strictly for users with a registration token (or session for pre-verified staff)
		onboardingGroup := v1.Group("/onboarding")
		onboardingGroup.Use(middleware.RequireAuth(cfg.JWTSecret, rdb), middleware.RequireOnboardingToken())
		{
			onboardingGroup.POST("/employer", onboardingHandler.OnboardEmployer)
			onboardingGroup.POST("/employee", onboardingHandler.OnboardEmployee)
			onboardingGroup.POST("/verifier", onboardingHandler.OnboardVerifier)
		}

		// Taxonomy
		v1.GET("/taxonomy", taxonomyHandler.GetTaxonomy)

		// Admin
		adminGroup := v1.Group("/admin")
		{
			// Global Admin Protection
			adminGroup.Use(middleware.RequireAuth(cfg.JWTSecret, rdb), middleware.RequireOnboardingToken())

			usersGroup := adminGroup.Group("/users")
			// Only SUPER_ADMIN and ADMIN (HR_ADMIN) can invite internal staff
			usersGroup.Use(middleware.RequireRoles(string(auth.RoleSuperAdmin), string(auth.RoleAdmin)))
			{
				usersGroup.GET("", adminHandler.GetManagementUsers)
				usersGroup.POST("/invite", adminHandler.InviteUser)
				usersGroup.PATCH("/:id/status", adminHandler.UpdateUserStatus)
				usersGroup.PATCH("/:id", adminHandler.UpdateUser)
				usersGroup.DELETE("/:id", adminHandler.DeleteUser)
			}

			superGroup := adminGroup.Group("/super")
			superGroup.Use(middleware.RequireRoles(string(auth.RoleSuperAdmin)))
			{
				superGroup.POST("/users", adminHandler.CreateManagementUser)
				superGroup.PATCH("/setup", adminHandler.UpdateSuperAdminSetup)
			}

			// Taxonomy Admin
			taxGroup := adminGroup.Group("/taxonomy")
			taxGroup.Use(middleware.RequireRoles(string(auth.RoleSuperAdmin)))
			{
				taxGroup.GET("/categories", taxonomyAdminHandler.GetAdminTaxonomy)
				taxGroup.POST("/categories", taxonomyAdminHandler.CreateCategory)
				taxGroup.PATCH("/categories/:id", taxonomyAdminHandler.UpdateCategory)
				taxGroup.POST("/categories/:categoryId/skills", taxonomyAdminHandler.CreateSkill)
				taxGroup.PATCH("/skills/:id", taxonomyAdminHandler.UpdateSkill)
			}

			// Platform Config
			adminGroup.GET("/config", middleware.RequireRoles(string(auth.RoleSuperAdmin)), adminHandler.GetPlatformConfig)
			adminGroup.PATCH("/config", middleware.RequireRoles(string(auth.RoleSuperAdmin)), adminHandler.UpdatePlatformConfig)

			// Dispute Resolution (Super Admin only for now)
			disputeGroup := adminGroup.Group("/disputes")
			disputeGroup.Use(middleware.RequireRoles(string(auth.RoleSuperAdmin)))
			{
				disputeGroup.GET("/pending", adminHandler.GetPendingDisputes)
				disputeGroup.POST("/:id/resolve", adminHandler.ResolveDispute)
			}
		}

		// Analytics
		analyticsGroup := v1.Group("/analytics")
		analyticsGroup.Use(middleware.RequireAuth(cfg.JWTSecret, rdb), middleware.RequireTokenType("session"))
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
		csGroup.Use(middleware.RequireAuth(cfg.JWTSecret, rdb), middleware.RequireTokenType("session"), middleware.RequireRoles(string(auth.RoleCSAgent), string(auth.RoleSuperAdmin)))
		{
			csGroup.GET("/users/search", csHandler.SearchUser)
			csGroup.POST("/users/:userId/notes", csHandler.AddNote)
			csGroup.GET("/users/:userId/notes", csHandler.GetNotes)
			csGroup.GET("/gigs/:gigId", csHandler.GetGigDetails)
			csGroup.POST("/gigs/:gigId/employees/:empId/recommend", csHandler.RecommendResolution)
		}

		// HR Admin
		hrGroup := v1.Group("/hr")
		hrGroup.Use(middleware.RequireAuth(cfg.JWTSecret, rdb), middleware.RequireTokenType("session"), middleware.RequireRoles(string(auth.RoleHRAdmin), string(auth.RoleSuperAdmin)))
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
		verifierGroup.Use(middleware.RequireAuth(cfg.JWTSecret, rdb), middleware.RequireTokenType("session"), middleware.RequireRoles(string(auth.RoleVerifier), string(auth.RoleSuperAdmin)))
		{
			verifierGroup.GET("/queue", verifierHandler.GetQueue)
			verifierGroup.GET("/history", verifierHandler.GetHistory)
			verifierGroup.GET("/profile", verifierHandler.GetProfile)
			verifierGroup.GET("/employers/:id", verifierHandler.GetEmployerDetails)
			verifierGroup.POST("/employers/:id/verify", verifierHandler.VerifyEmployer)
			verifierGroup.POST("/employees/:id/verify", verifierHandler.VerifyEmployee)
		}

		// Storage Proxy
		v1.GET("/storage/*filepath", func(c *gin.Context) {
			path := c.Param("filepath")
			path = strings.TrimPrefix(path, "/")
			
			parts := strings.SplitN(path, "/", 2)
			if len(parts) < 2 {
				log.Printf("Storage Proxy: Invalid path format: %s", path)
				c.AbortWithStatus(404)
				return
			}
			bucket, object := parts[0], parts[1]

			reader, size, err := storageSvc.GetFile(c.Request.Context(), bucket, object)
			if err != nil {
				log.Printf("Storage Proxy Error: Failed to get file %s from bucket %s: %v", object, bucket, err)
				c.AbortWithStatus(404)
				return
			}
			defer reader.Close()

			contentType := "application/octet-stream"
			if strings.HasSuffix(object, ".jpg") || strings.HasSuffix(object, ".jpeg") {
				contentType = "image/jpeg"
			} else if strings.HasSuffix(object, ".png") {
				contentType = "image/png"
			} else if strings.HasSuffix(object, ".pdf") {
				contentType = "application/pdf"
			}

			c.DataFromReader(200, size, contentType, reader, nil)
		})

		// Employer & Gigs
		employerGroup := v1.Group("/employers")
		employerGroup.Use(middleware.RequireAuth(cfg.JWTSecret, rdb), middleware.RequireTokenType("session"), middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)))
		{
			employerGroup.GET("/me", employerHandler.GetProfile)
			employerGroup.GET("/me/gigs", employerHandler.GetMyGigs)
			employerGroup.POST("/me/subscription", employerHandler.PurchaseSubscription)
			employerGroup.GET("/profiles/employees/:empId", employerHandler.GetEmployeeProfile)
		}

		gigGroup := v1.Group("/gigs")
		gigGroup.Use(middleware.RequireAuth(cfg.JWTSecret, rdb), middleware.RequireTokenType("session"))
		{
			gigGroup.GET("/wage-benchmark", gigHandler.GetBenchmark)
			
			// Employer only actions
			gigGroup.POST("", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.PostGig)
			gigGroup.POST("/:gigId/confirm-payment", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.ConfirmMockPayment)
			gigGroup.GET("/search", middleware.RequireRoles(string(auth.RoleWorker), string(auth.RoleSuperAdmin)), gigHandler.SearchGigs)
			gigGroup.POST("/:gigId/apply", middleware.RequireRoles(string(auth.RoleWorker), string(auth.RoleSuperAdmin)), gigHandler.ApplyForGig)
			gigGroup.POST("/:gigId/confirm-attendance", middleware.RequireRoles(string(auth.RoleWorker), string(auth.RoleSuperAdmin)), gigHandler.ConfirmAttendance)
			gigGroup.POST("/:gigId/scan-qr", middleware.RequireRoles(string(auth.RoleWorker), string(auth.RoleSuperAdmin)), gigHandler.ScanQR)
			gigGroup.POST("/:gigId/employer-review", middleware.RequireRoles(string(auth.RoleWorker), string(auth.RoleSuperAdmin)), gigHandler.SubmitEmployerReview)
			gigGroup.POST("/:gigId/revoke-application", middleware.RequireRoles(string(auth.RoleWorker), string(auth.RoleSuperAdmin)), gigHandler.RevokeApplication)
			
			gigGroup.GET("/:gigId/applications", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.GetApplications)
			gigGroup.POST("/:gigId/cancel", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.CancelGig)
			gigGroup.POST("/:gigId/cancel/otp", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.RequestCancelOTP)
			gigGroup.POST("/:gigId/cancel/verify", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.VerifyCancelAndConfirm)
			gigGroup.POST("/:gigId/close-unfilled", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.CloseUnfilled)
			gigGroup.GET("/:gigId/attendance-qr", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.GenerateQR)
			gigGroup.POST("/:gigId/employees/:empId/mark-arrived", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.MarkArrived)
			gigGroup.POST("/:gigId/employees/:empId/complete", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.CompleteShift)
			gigGroup.POST("/:gigId/emergency-hire", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.EmergencyHire)
			gigGroup.POST("/:gigId/employees/:empId/review", middleware.RequireRoles(string(auth.RoleEmployer), string(auth.RoleSuperAdmin)), gigHandler.SubmitReview)
		}

		appGroup := v1.Group("/applications")
		appGroup.Use(middleware.RequireAuth(cfg.JWTSecret, rdb), middleware.RequireTokenType("session"))
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
			employeeGroup.POST("/me/skills", employeeHandler.AddSkill)
			employeeGroup.DELETE("/me/skills/:skillId", employeeHandler.DeleteSkill)
			employeeGroup.POST("/me/certifications", employeeHandler.AddCertification)
			employeeGroup.DELETE("/me/certifications/:certId", employeeHandler.DeleteCertification)
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

func seedDefaultSuperAdmin(db *gorm.DB) {
	var count int64
	db.Model(&auth.User{}).Where("role = ?", auth.RoleSuperAdmin).Count(&count)
	if count == 0 {
		root := &auth.User{
			Email:                  "root@shiftley.in",
			PhoneNumber:            "+910000000000",
			FullName:               "Root Super Admin",
			Role:                   auth.RoleSuperAdmin,
			IsVerified:             true,
			IsInitialSetupComplete: false,
		}
		if err := db.Create(root).Error; err != nil {
			log.Printf("Warning: Failed to seed default Super Admin: %v", err)
		} else {
			log.Println("Default Super Admin created: +910000000000")
		}
	}
}
