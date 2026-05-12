package auth

import (
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
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
	ProfilePhotoURL string      `json:"profile_photo_url"`
	BankAccount  string         `json:"bank_account"`
	BankIFSC     string         `json:"bank_ifsc"`
	LastLoginAt  *time.Time     `json:"last_login_at"`
	IsInitialSetupComplete bool           `gorm:"default:false" json:"is_initial_setup_complete"`
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

type WorkerProfile struct {
	ID                uuid.UUID      `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	UserID            uuid.UUID      `gorm:"type:uuid;not null;unique;index" json:"user_id"`
	Lat               float64        `gorm:"type:decimal(10,8)" json:"lat"`
	Lng               float64        `gorm:"type:decimal(11,8)" json:"lng"`
	Location          string         `gorm:"type:geography(Point, 4326)" json:"-"` // Internal PostGIS field
	SearchRadiusKM    int            `gorm:"default:10" json:"search_radius_km"`
	ReliabilityScore  int            `gorm:"default:100" json:"reliability_score"`
	TotalGigs         int            `gorm:"default:0" json:"total_gigs"`
	TotalNoShows      int            `gorm:"default:0" json:"total_no_shows"`
	LastNoShowAt      *time.Time     `json:"last_no_show_at"`
	ProfilePhotoURL   string         `json:"profile_photo_url"`
	Degree            string         `json:"degree"`
	Specialization    string         `json:"specialization"`
	PassingYear       int            `json:"passing_year"`
	Skills            pq.StringArray `gorm:"type:text[]" json:"skill_ids"` // Simplified Skill IDs
	CreatedAt         time.Time      `json:"created_at"`
	UpdatedAt         time.Time      `json:"updated_at"`
	DeletedAt         gorm.DeletedAt `gorm:"index" json:"-"`
}

func (WorkerProfile) TableName() string {
	return "shiftley.worker_profiles"
}

type EmployerProfile struct {
	ID                uuid.UUID      `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	UserID            uuid.UUID      `gorm:"type:uuid;not null;unique;index" json:"user_id"`
	BusinessName      string         `gorm:"not null" json:"business_name"`
	BusinessType      string         `gorm:"not null" json:"business_type"`
	GSTNumber         string         `json:"gst_number"`
	Email             string         `gorm:"<-:false" json:"email"`
	PhoneNumber       string         `gorm:"<-:false" json:"phone_number"`
	FullName          string         `gorm:"<-:false" json:"full_name"`
	BusinessAddress   string         `gorm:"type:text;not null" json:"business_address"`
	Lat               float64        `gorm:"type:decimal(10,8)" json:"lat"`
	Lng               float64        `gorm:"type:decimal(11,8)" json:"lng"`
	Location          string         `gorm:"type:geography(Point, 4326)" json:"-"`
	VerificationStatus string         `gorm:"default:'PENDING'" json:"verification_status"`
	AadhaarLast4      string         `json:"aadhaar_last_4"`
	AadhaarURL        string         `json:"aadhaar_url"`
	PhotoURLs         pq.StringArray `gorm:"type:text[]" json:"photo_urls"`
	CreatedAt         time.Time      `json:"created_at"`
	UpdatedAt         time.Time      `json:"updated_at"`
	DeletedAt         gorm.DeletedAt `gorm:"index" json:"-"`
}

func (EmployerProfile) TableName() string {
	return "shiftley.employer_profiles"
}
