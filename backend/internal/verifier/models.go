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
