package main

import (
	"fmt"
	"log"
	"shiftley/internal/admin"
	"shiftley/internal/auth"
	"shiftley/internal/config"
	"shiftley/internal/employee"
	"shiftley/internal/employer"
	"shiftley/internal/gig"
	"shiftley/internal/onboarding"
	"shiftley/internal/support"
	"shiftley/internal/taxonomy"
	"shiftley/internal/verifier"
	"shiftley/pkg/middleware"
	"shiftley/pkg/storage"
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
	db.AutoMigrate(&auth.User{}, &auth.OTP{}, &auth.KYCSession{}, &taxonomy.Category{}, &taxonomy.Skill{}, &config.PlatformConfig{}, &verifier.VerificationAudit{}, &employer.Subscription{}, &gig.Gig{}, &gig.GigApplication{})

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

	// 5. Initialize Handlers & Services
	authRepo := auth.NewRepository(db, rdb)
	authSvc := auth.NewService(authRepo, cfg.JWTSecret)
	authHandler := auth.NewHandler(authSvc)
	
	onboardingHandler := onboarding.NewHandler(storageSvc, cfg.BucketProfiles, cfg.BucketLogos, cfg.BucketKYC)

	adminHandler := admin.NewHandler(db, rdb)
	taxonomyAdminHandler := admin.NewTaxonomyHandler(db)
	employerHandler := employer.NewHandler(db)
	gigHandler := gig.NewHandler(db)
	employeeHandler := employee.NewHandler(db)
	supportHandler := support.NewHandler(db)

	verifierRepo := verifier.NewRepository(db)
	verifierHandler := verifier.NewHandler(verifierRepo, storageSvc, cfg.BucketKYC)

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
			employeeGroup.POST("/me/pay-fine", employeeHandler.PayFine)
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
