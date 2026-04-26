package gig

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type GigStatus string

const (
	StatusDraft     GigStatus = "DRAFT"
	StatusOpen      GigStatus = "OPEN"
	StatusFilled    GigStatus = "FILLED"
	StatusCompleted GigStatus = "COMPLETED"
	StatusCancelled GigStatus = "CANCELLED"
)

type Gig struct {
	ID             uuid.UUID      `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	EmployerID     uuid.UUID      `gorm:"type:uuid;not null;index" json:"employer_id"`
	Title          string         `gorm:"not null" json:"title"`
	Description    string         `gorm:"type:text" json:"description"`
	CategoryID     string         `gorm:"not null;index" json:"category_id"`
	SkillID        string         `gorm:"not null;index" json:"skill_id"`
	Lat            float64        `gorm:"type:decimal(10,8)" json:"lat"`
	Lng            float64        `gorm:"type:decimal(11,8)" json:"lng"`
	Address        string         `gorm:"type:text" json:"address"`
	StartTime      time.Time      `gorm:"not null" json:"start_time"`
	EndTime        time.Time      `gorm:"not null" json:"end_time"`
	PayType        string         `gorm:"type:varchar(10);not null" json:"pay_type"` // PER_DAY, PER_HOUR
	WagePerWorker  int64          `gorm:"not null" json:"wage_per_worker"`          // In Paise
	WorkersNeeded  int            `gorm:"not null;default:1" json:"workers_needed"`
	Status         GigStatus      `gorm:"type:varchar(20);default:'DRAFT'" json:"status"`
	CancelReason   string         `json:"cancel_reason"`
	EscrowOrderID  string         `json:"escrow_order_id"`
	IsEscrowFunded bool           `gorm:"default:false" json:"is_escrow_funded"`
	CreatedAt      time.Time      `json:"created_at"`
	UpdatedAt      time.Time      `json:"updated_at"`
	DeletedAt      gorm.DeletedAt `gorm:"index" json:"-"`
}

func (Gig) TableName() string {
	return "shiftley.gigs"
}

type AttendanceStatus string

const (
	AttPresent AttendanceStatus = "PRESENT"
	AttAbsent  AttendanceStatus = "ABSENT"
	AttNoShow   AttendanceStatus = "NO_SHOW"
)

type GigAttendance struct {
	ID         uuid.UUID        `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	GigID      uuid.UUID        `gorm:"type:uuid;not null;index" json:"gig_id"`
	EmployeeID uuid.UUID        `gorm:"type:uuid;not null;index" json:"employee_id"`
	ClockIn    *time.Time       `json:"clock_in"`
	ClockOut   *time.Time       `json:"clock_out"`
	Status     AttendanceStatus `gorm:"type:varchar(20);default:'ABSENT'" json:"status"`
	CreatedAt  time.Time        `json:"created_at"`
	UpdatedAt  time.Time        `json:"updated_at"`
}

func (GigAttendance) TableName() string {
	return "shiftley.gig_attendance"
}

type GigReview struct {
	ID         uuid.UUID      `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	GigID      uuid.UUID      `gorm:"type:uuid;not null;index" json:"gig_id"`
	FromUserID uuid.UUID      `gorm:"type:uuid;not null;index" json:"from_user_id"`
	ToUserID   uuid.UUID      `gorm:"type:uuid;not null;index" json:"to_user_id"`
	Rating     int            `gorm:"not null" json:"rating"`
	Comment    string         `gorm:"type:text" json:"comment"`
	CreatedAt  time.Time      `json:"created_at"`
	DeletedAt  gorm.DeletedAt `gorm:"index" json:"-"`
}

func (GigReview) TableName() string {
	return "shiftley.gig_reviews"
}

type SupportTicket struct {
	ID           uuid.UUID      `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	UserID       uuid.UUID      `gorm:"type:uuid;not null;index" json:"user_id"`
	GigID        *uuid.UUID     `gorm:"type:uuid;index" json:"gig_id"`
	Subject      string         `gorm:"not null" json:"subject"`
	Description  string         `gorm:"type:text" json:"description"`
	Status       string         `gorm:"type:varchar(20);default:'OPEN'" json:"status"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`
}

func (SupportTicket) TableName() string {
	return "shiftley.support_tickets"
}

type ApplicationStatus string

const (
	AppApplied  ApplicationStatus = "APPLIED"
	AppApproved ApplicationStatus = "APPROVED"
	AppRejected ApplicationStatus = "REJECTED"
	AppNoShow   ApplicationStatus = "NO_SHOW"
)

type GigApplication struct {
	ID         uuid.UUID         `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	GigID      uuid.UUID         `gorm:"type:uuid;not null;index" json:"gig_id"`
	EmployeeID uuid.UUID         `gorm:"type:uuid;not null;index" json:"employee_id"`
	Status     ApplicationStatus `gorm:"type:varchar(20);default:'APPLIED'" json:"status"`
	Notes      string            `json:"notes"`
	CreatedAt  time.Time         `json:"created_at"`
	UpdatedAt  time.Time         `json:"updated_at"`
	DeletedAt  gorm.DeletedAt    `gorm:"index" json:"-"`
}

func (GigApplication) TableName() string {
	return "shiftley.gig_applications"
}
