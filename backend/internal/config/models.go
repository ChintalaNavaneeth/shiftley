package config

import (
	"time"

	"gorm.io/gorm"
)

type PlatformConfig struct {
	ID                         uint           `gorm:"primaryKey" json:"id"`
	EmployerSubscriptionMonthly float64        `gorm:"-" json:"employer_subscription_monthly"`
	EmployerSubscriptionWeekly  float64        `gorm:"-" json:"employer_subscription_weekly"`
	EmployerSubscriptionDaily   float64        `gorm:"-" json:"employer_subscription_daily"`
	WorkerNoShowPenalty         float64        `gorm:"default:50.00" json:"worker_no_show_penalty"`
	EmployerCancelPenalty6h     float64        `gorm:"default:10.00" json:"employer_cancel_penalty_6h"`
	EmployerCancelPenalty3h     float64        `gorm:"default:25.00" json:"employer_cancel_penalty_3h"`
	EmployerCancelPenalty1h     float64        `gorm:"default:50.00" json:"employer_cancel_penalty_1h"`
	UpdatedAt                  time.Time      `json:"updated_at"`
	DeletedAt                  gorm.DeletedAt `gorm:"index" json:"-"`
}

func (PlatformConfig) TableName() string {
	return "shiftley.platform_config"
}
