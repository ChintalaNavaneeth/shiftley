package cs

import (
	"time"

	"github.com/google/uuid"
)

type AccountNote struct {
	ID        uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	UserID    uuid.UUID `gorm:"type:uuid;not null;index" json:"user_id"`
	AgentID   uuid.UUID `gorm:"type:uuid;not null;index" json:"agent_id"`
	Category  string    `gorm:"type:varchar(50);not null" json:"category"`
	Note      string    `gorm:"type:text;not null" json:"note"`
	CreatedAt time.Time `json:"created_at"`
}

type ResolutionStatus string

const (
	StatusPending  ResolutionStatus = "PENDING"
	StatusApproved ResolutionStatus = "APPROVED"
	StatusRejected ResolutionStatus = "REJECTED"
)

type DisputeResolutionRequest struct {
	ID             uuid.UUID        `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	GigID          uuid.UUID        `gorm:"type:uuid;not null;index" json:"gig_id"`
	EmployeeID     uuid.UUID        `gorm:"type:uuid;not null;index" json:"employee_id"`
	CSAgentID      uuid.UUID        `gorm:"type:uuid;not null;index" json:"cs_agent_id"`
	AdminID        *uuid.UUID       `gorm:"type:uuid;index" json:"admin_id"`
	Recommendation string           `gorm:"type:varchar(50);not null" json:"recommendation"` // REFUND_EMPLOYER, PAY_WORKER
	Reason         string           `gorm:"type:text;not null" json:"reason"`
	AmountPaise    int64            `gorm:"not null" json:"amount_paise"`
	Status         ResolutionStatus `gorm:"type:varchar(20);default:'PENDING'" json:"status"`
	CreatedAt      time.Time        `json:"created_at"`
	UpdatedAt      time.Time        `json:"updated_at"`
}

func (AccountNote) TableName() string {
	return "shiftley.account_notes"
}

func (DisputeResolutionRequest) TableName() string {
	return "shiftley.dispute_resolution_requests"
}
