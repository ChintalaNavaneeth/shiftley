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
	MinioPassword string `mapstructure:"MINIO_ROOT_PASSWORD"`
}

var GlobalConfig *Config

func LoadConfig() *Config {
	viper.AutomaticEnv()

	// Explicitly bind environment variables to match struct tags if needed
	// Or just rely on AutomaticEnv which usually works if names match perfectly (case insensitive)
	// But let's be explicit to avoid "empty string" issues
	envVars := []string{
		"APP_PORT", "DB_HOST", "DB_PORT", "DB_USER", "DB_PASSWORD", "DB_NAME",
		"REDIS_HOST", "REDIS_PORT", "REDIS_PASSWORD", "JWT_SECRET",
		"MINIO_ENDPOINT", "MINIO_ROOT_USER", "MINIO_ROOT_PASSWORD",
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
		MinioPassword: getEnv("MINIO_ROOT_PASSWORD", "minioadmin"),
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
