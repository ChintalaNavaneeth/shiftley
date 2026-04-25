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
