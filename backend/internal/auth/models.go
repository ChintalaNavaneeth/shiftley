package auth

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type UserRole string

const (
	RoleWorker     UserRole = "WORKER"
	RoleEmployer   UserRole = "EMPLOYER"
	RoleVerifier   UserRole = "VERIFIER"
	RoleCSAgent    UserRole = "CS_AGENT"
	RoleAnalyst    UserRole = "ANALYST"
	RoleAdmin      UserRole = "ADMIN"
	RoleHRAdmin    UserRole = "HR_ADMIN"
	RoleSuperAdmin UserRole = "SUPER_ADMIN"
)

type User struct {
	ID           uuid.UUID      `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	Email        string         `gorm:"uniqueIndex;not null" json:"email"`
	PasswordHash string         `gorm:"not null" json:"-"`
	PhoneNumber  string         `gorm:"uniqueIndex" json:"phone_number"`
	FullName     string         `gorm:"not null" json:"full_name"`
	Role         UserRole       `gorm:"type:varchar(20);not null" json:"role"`
	IsVerified   bool           `gorm:"default:false" json:"is_verified"`
	IsSuspended  bool           `gorm:"default:false" json:"is_suspended"`
	UnpaidFinePaise int64        `gorm:"default:0" json:"unpaid_fine_paise"`
	UPIID        string         `json:"upi_id"`
	BankAccount  string         `json:"bank_account"`
	BankIFSC     string         `json:"bank_ifsc"`
	LastLoginAt  *time.Time     `json:"last_login_at"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`
}

func (u *User) TableName() string {
	return "shiftley.users"
}

type OTP struct {
	ID        uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	UserID    uuid.UUID `gorm:"type:uuid;not null" json:"user_id"`
	Channel   string    `gorm:"type:varchar(10)" json:"channel"` // EMAIL, WHATSAPP
	Code      string    `gorm:"type:varchar(10);not null" json:"code"`
	ExpiresAt time.Time `gorm:"not null" json:"expires_at"`
	IsUsed    bool      `gorm:"default:false" json:"is_used"`
	CreatedAt time.Time `json:"created_at"`
}

func (o *OTP) TableName() string {
	return "shiftley.otps"
}

type KYCSession struct {
	ID                uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	UserID            uuid.UUID `gorm:"type:uuid;not null;unique" json:"user_id"`
	Provider          string    `gorm:"default:'HYPERVERGE'" json:"provider"`
	ProviderSessionID string    `json:"provider_session_id"`
	Status            string    `gorm:"default:'PENDING'" json:"status"`
	MaskedAadhaar     string    `json:"masked_aadhaar"`
	FaceMatchScore    float64   `json:"face_match_score"`
	VerifiedAt        *time.Time `json:"verified_at"`
	DocumentURL       string    `json:"document_url"`
	CreatedAt         time.Time `json:"created_at"`
}

func (k *KYCSession) TableName() string {
	return "shiftley.kyc_sessions"
}
