package verifier

import (
	"context"
	"time"

	"shiftley/internal/auth"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Repository interface {
	GetPendingQueue(ctx context.Context, userType string, limit int) ([]QueueItem, error)
	SubmitVerification(ctx context.Context, audit *VerificationAudit, kycStatus string) error
	GetVerificationHistory(ctx context.Context, verifierID uuid.UUID, limit int) ([]VerificationAudit, error)
	GetVerifierProfile(ctx context.Context, userID uuid.UUID) (*VerifierProfile, error)
}

type QueueItem struct {
	UserID        uuid.UUID `json:"user_id"`
	FullName      string    `json:"full_name"`
	Email         string    `json:"email"`
	Role          string    `json:"role"`
	KYCStatus     string    `json:"kyc_status"`
	MaskedAadhaar string    `json:"masked_aadhaar"`
	CreatedAt     time.Time `json:"created_at"`
}

type repository struct {
	db *gorm.DB
}

func NewRepository(db *gorm.DB) Repository {
	return &repository{db: db}
}

func (r *repository) GetPendingQueue(ctx context.Context, userType string, limit int) ([]QueueItem, error) {
	var items []QueueItem
	
	query := r.db.WithContext(ctx).Table("shiftley.users").
		Select("shiftley.users.id as user_id, shiftley.users.full_name, shiftley.users.email, shiftley.users.role, shiftley.kyc_sessions.status as kyc_status, shiftley.kyc_sessions.masked_aadhaar, shiftley.users.created_at").
		Joins("JOIN shiftley.kyc_sessions ON shiftley.kyc_sessions.user_id = shiftley.users.id").
		Where("shiftley.kyc_sessions.status = ?", "PENDING")

	if userType != "" {
		query = query.Where("shiftley.users.role = ?", userType)
	}

	err := query.Limit(limit).Scan(&items).Error
	return items, err
}

func (r *repository) SubmitVerification(ctx context.Context, audit *VerificationAudit, kycStatus string) error {
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		// 1. Save Audit
		if err := tx.Create(audit).Error; err != nil {
			return err
		}

		// 2. Update KYC Session
		updates := map[string]interface{}{
			"status":      kycStatus,
			"verified_at": time.Now(),
		}
		if err := tx.Model(&auth.KYCSession{}).Where("user_id = ?", audit.UserID).Updates(updates).Error; err != nil {
			return err
		}

		// 3. Update User Status if Approved
		if kycStatus == "VERIFIED" {
			if err := tx.Model(&auth.User{}).Where("id = ?", audit.UserID).Update("is_verified", true).Error; err != nil {
				return err
			}
		}

		return nil
	})
}

func (r *repository) GetVerificationHistory(ctx context.Context, verifierID uuid.UUID, limit int) ([]VerificationAudit, error) {
	var audits []VerificationAudit
	err := r.db.WithContext(ctx).Where("verifier_id = ?", verifierID).Order("created_at DESC").Limit(limit).Find(&audits).Error
	return audits, err
}

func (r *repository) GetVerifierProfile(ctx context.Context, userID uuid.UUID) (*VerifierProfile, error) {
	var profile VerifierProfile
	err := r.db.WithContext(ctx).Table("shiftley.verifier_profiles").
		Select("shiftley.verifier_profiles.id, shiftley.verifier_profiles.user_id, shiftley.verifier_profiles.profile_photo_url, shiftley.verifier_profiles.aadhaar_url, shiftley.verifier_profiles.lat, shiftley.verifier_profiles.lng, shiftley.verifier_profiles.created_at, shiftley.users.full_name, shiftley.users.email, shiftley.users.phone_number, shiftley.users.role").
		Joins("JOIN shiftley.users ON shiftley.users.id = shiftley.verifier_profiles.user_id").
		Where("shiftley.verifier_profiles.user_id = ?", userID).
		First(&profile).Error
	if err != nil {
		return nil, err
	}
	return &profile, nil
}
