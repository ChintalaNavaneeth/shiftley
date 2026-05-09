package verifier

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type VerificationAudit struct {
	ID               uuid.UUID      `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	UserID           uuid.UUID      `gorm:"type:uuid;not null;index" json:"user_id"`
	VerifierID       uuid.UUID      `gorm:"type:uuid;not null;index" json:"verifier_id"`
	Status           string         `gorm:"type:varchar(20);not null" json:"status"` // APPROVED, REJECTED
	Notes            string         `gorm:"type:text" json:"notes"`
	VerifierSelfieURL string        `json:"verifier_selfie_url"`
	LocationPhoto1URL string        `json:"location_photo_1_url"`
	LocationPhoto2URL string        `json:"location_photo_2_url"`
	LocationPhoto3URL string        `json:"location_photo_3_url"`
	VerifiedLat      float64        `json:"verified_lat"`
	VerifiedLng      float64        `json:"verified_lng"`
	CreatedAt        time.Time      `json:"created_at"`
	UpdatedAt        time.Time      `json:"updated_at"`
	DeletedAt        gorm.DeletedAt `gorm:"index" json:"-"`
}

func (VerificationAudit) TableName() string {
	return "shiftley.verification_audits"
}

type VerifierProfile struct {
	ID              uuid.UUID      `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	UserID          uuid.UUID      `gorm:"type:uuid;not null;uniqueIndex" json:"user_id"`
	FullName        string         `gorm:"->" json:"full_name"`
	Email           string         `gorm:"->" json:"email"`
	PhoneNumber     string         `gorm:"->" json:"phone_number"`
	Role            string         `gorm:"->" json:"role"`
	ProfilePhotoURL string         `json:"profile_photo_url"`
	AadhaarURL      string         `json:"aadhaar_url"`
	Lat             float64        `json:"lat"`
	Lng             float64        `json:"lng"`
	Location        string         `gorm:"type:geometry(Point,4326)" json:"-"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	DeletedAt       gorm.DeletedAt `gorm:"index" json:"-"`
}

func (VerifierProfile) TableName() string {
	return "shiftley.verifier_profiles"
}
