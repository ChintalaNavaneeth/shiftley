package config

import (
	"time"

	"gorm.io/gorm"
)

type PlatformConfig struct {
	ID                         uint           `gorm:"primaryKey" json:"id"`
	EmployerSubscriptionMonthly float64        `gorm:"default:679.00" json:"employer_subscription_monthly"`
	EmployerSubscriptionWeekly  float64        `gorm:"default:199.00" json:"employer_subscription_weekly"`
	EmployerPerDayFee           float64        `gorm:"default:99.00" json:"employer_per_day_fee"`
	WorkerCancelPenalty        float64        `gorm:"default:50.00" json:"worker_cancel_penalty"`
	UpdatedAt                  time.Time      `json:"updated_at"`
	DeletedAt                  gorm.DeletedAt `gorm:"index" json:"-"`
}

func (PlatformConfig) TableName() string {
	return "shiftley.platform_config"
}
