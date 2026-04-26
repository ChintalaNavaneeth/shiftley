package analytics

import (
	"time"

	"github.com/google/uuid"
)

type ExpenditureCategory string

const (
	ExpMarketing      ExpenditureCategory = "MARKETING"
	ExpInfrastructure ExpenditureCategory = "INFRASTRUCTURE"
	ExpPayroll        ExpenditureCategory = "PAYROLL"
	ExpOther          ExpenditureCategory = "OTHER"
)

type Expenditure struct {
	ID          uuid.UUID           `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	Month       string              `gorm:"type:varchar(7);not null;index" json:"month"` // YYYY-MM
	Category    ExpenditureCategory `gorm:"type:varchar(30);not null" json:"category"`
	AmountPaise int64               `gorm:"not null" json:"amount_paise"`
	Description string              `gorm:"type:text" json:"description"`
	CreatedAt   time.Time           `json:"created_at"`
}

func (Expenditure) TableName() string {
	return "shiftley.expenditures"
}
