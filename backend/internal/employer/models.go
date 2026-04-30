package employer

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type SubscriptionPlan string

const (
	PlanDaily   SubscriptionPlan = "DAILY"
	PlanWeekly  SubscriptionPlan = "WEEKLY"
	PlanMonthly SubscriptionPlan = "MONTHLY"
	PlanNone    SubscriptionPlan = "NONE"
)

type SubscriptionPlanMeta struct {
	ID          string  `gorm:"primaryKey" json:"id"`
	Name        string  `json:"name"`
	PricePaise  int64   `json:"price_paise"`
	DurationDay int     `json:"duration_days"`
	IsActive    bool    `gorm:"default:true" json:"is_active"`
}

func (SubscriptionPlanMeta) TableName() string {
	return "shiftley.subscription_plans"
}


type Subscription struct {
	ID         uuid.UUID        `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	EmployerID uuid.UUID        `gorm:"type:uuid;not null;index" json:"employer_id"`
	PlanID     SubscriptionPlan `gorm:"type:varchar(20);not null" json:"plan_id"`
	StartDate  time.Time        `json:"start_date"`
	EndDate    time.Time        `json:"end_date"`
	IsActive   bool             `gorm:"default:true" json:"is_active"`
	CreatedAt  time.Time        `json:"created_at"`
	UpdatedAt  time.Time        `json:"updated_at"`
	DeletedAt  gorm.DeletedAt   `gorm:"index" json:"-"`
}

func (Subscription) TableName() string {
	return "shiftley.subscriptions"
}

type EmployerStats struct {
	TotalGigsPosted   int64            `json:"total_gigs_posted"`
	FreeGigsRemaining int              `json:"free_gigs_remaining"`
	ActivePlan        SubscriptionPlan `json:"active_plan"`
	PlanExpiresAt     *time.Time       `json:"plan_expires_at"`
}
