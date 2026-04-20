package main

import (
	"fmt"
	"log"
	"shiftley/internal/auth"
	"shiftley/internal/config"
	"shiftley/internal/onboarding"
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

	// 6. Setup Router
	r := gin.Default()

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
			onboardingGroup.POST("/employee", onboardingHandler.OnboardEmployee)
		}
	}

	fmt.Printf("Shiftley Backend starting on :%s...\n", cfg.AppPort)
	if err := r.Run(":" + cfg.AppPort); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
