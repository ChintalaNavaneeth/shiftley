package config

import (
	"github.com/spf13/viper"
)

type Config struct {
	AppPort       string `mapstructure:"APP_PORT"`
	DBHost        string `mapstructure:"DB_HOST"`
	DBPort        string `mapstructure:"DB_PORT"`
	DBUser        string `mapstructure:"DB_USER"`
	DBPassword    string `mapstructure:"DB_PASSWORD"`
	DBName        string `mapstructure:"DB_NAME"`
	RedisHost     string `mapstructure:"REDIS_HOST"`
	RedisPort     string `mapstructure:"REDIS_PORT"`
	RedisPassword string `mapstructure:"REDIS_PASSWORD"`
	JWTSecret     string `mapstructure:"JWT_SECRET"`
	MinioEndpoint string `mapstructure:"MINIO_ENDPOINT"`
	MinioUser     string `mapstructure:"MINIO_ROOT_USER"`
	MinioPassword  string `mapstructure:"MINIO_ROOT_PASSWORD"`
	BucketProfiles string `mapstructure:"BUCKET_PROFILES"`
	BucketLogos    string `mapstructure:"BUCKET_LOGOS"`
	BucketKYC      string `mapstructure:"BUCKET_KYC"`
	// WhatsApp Business Cloud API (Meta)
	// Leave empty to run in mock mode (logs to stdout, no real messages sent)
	WhatsAppPhoneNumberID string `mapstructure:"WHATSAPP_PHONE_NUMBER_ID"`
	WhatsAppAccessToken   string `mapstructure:"WHATSAPP_ACCESS_TOKEN"`
	RazorpayWebhookSecret string `mapstructure:"RAZORPAY_WEBHOOK_SECRET"`
	WhatsAppWebhookSecret string `mapstructure:"WHATSAPP_WEBHOOK_SECRET"`
}

var GlobalConfig *Config

func LoadConfig() *Config {
	viper.AutomaticEnv()

	// Explicitly bind environment variables to match struct tags if needed
	// Or just rely on AutomaticEnv which usually works if names match perfectly (case insensitive)
	// But let's be explicit to avoid "empty string" issues
	envVars := []string{
		"APP_PORT", "DB_HOST", "DB_PORT", "DB_USER", "DB_PASSWORD", "DB_NAME",
		"MINIO_ENDPOINT", "MINIO_ROOT_USER", "MINIO_ROOT_PASSWORD",
		"BUCKET_PROFILES", "BUCKET_LOGOS", "BUCKET_KYC",
		"WHATSAPP_PHONE_NUMBER_ID", "WHATSAPP_ACCESS_TOKEN",
		"RAZORPAY_WEBHOOK_SECRET", "WHATSAPP_WEBHOOK_SECRET",
	}
	for _, env := range envVars {
		viper.BindEnv(env)
	}

	config := &Config{
		AppPort:       getEnv("APP_PORT", "8080"),
		DBHost:        getEnv("DB_HOST", "localhost"),
		DBPort:        getEnv("DB_PORT", "5432"),
		DBUser:        getEnv("DB_USER", "postgres"),
		DBPassword:    getEnv("DB_PASSWORD", ""),
		DBName:        getEnv("DB_NAME", "postgres"),
		RedisHost:     getEnv("REDIS_HOST", "localhost"),
		RedisPort:     getEnv("REDIS_PORT", "6379"),
		RedisPassword: getEnv("REDIS_PASSWORD", ""),
		JWTSecret:     getEnv("JWT_SECRET", "shiftley_secret_dev_123"),
		MinioEndpoint: getEnv("MINIO_ENDPOINT", "localhost:9000"),
		MinioUser:     getEnv("MINIO_ROOT_USER", "minioadmin"),
		MinioPassword:  getEnv("MINIO_ROOT_PASSWORD", "minioadmin"),
		BucketProfiles: getEnv("BUCKET_PROFILES", "profile-pics"),
		BucketLogos:    getEnv("BUCKET_LOGOS", "business-logos"),
		BucketKYC:      getEnv("BUCKET_KYC", "kyc-documents"),
		// WhatsApp: defaults to empty → mock mode enabled
		WhatsAppPhoneNumberID: getEnv("WHATSAPP_PHONE_NUMBER_ID", ""),
		WhatsAppAccessToken:   getEnv("WHATSAPP_ACCESS_TOKEN", ""),
		RazorpayWebhookSecret: getEnv("RAZORPAY_WEBHOOK_SECRET", "razorpay_secret_dev"),
		WhatsAppWebhookSecret: getEnv("WHATSAPP_WEBHOOK_SECRET", "whatsapp_secret_dev"),
	}

	GlobalConfig = config
	return config
}

func getEnv(key, defaultValue string) string {
	if value := viper.GetString(key); value != "" {
		return value
	}
	return defaultValue
}
