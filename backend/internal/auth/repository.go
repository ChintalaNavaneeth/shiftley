package auth

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"
	"gorm.io/gorm"
)

type Repository interface {
	GetUserByPhone(ctx context.Context, phone string) (*User, error)
	CreateUser(ctx context.Context, user *User) error
	CreateOTP(ctx context.Context, otp *OTP) error
	GetLatestOTP(ctx context.Context, userID uuid.UUID, channel string) (*OTP, error)
	MarkOTUsed(ctx context.Context, otpID uuid.UUID) error
	StoreSession(ctx context.Context, userID string, token string, expiration time.Duration) error
}

type repository struct {
	db    *gorm.DB
	redis *redis.Client
}

func NewRepository(db *gorm.DB, redis *redis.Client) Repository {
	return &repository{db: db, redis: redis}
}

func (r *repository) GetUserByPhone(ctx context.Context, phone string) (*User, error) {
	var user User
	err := r.db.WithContext(ctx).Where("phone_number = ?", phone).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *repository) CreateUser(ctx context.Context, user *User) error {
	return r.db.WithContext(ctx).Create(user).Error
}

func (r *repository) CreateOTP(ctx context.Context, otp *OTP) error {
	return r.db.WithContext(ctx).Create(otp).Error
}

func (r *repository) GetLatestOTP(ctx context.Context, userID uuid.UUID, channel string) (*OTP, error) {
	var otp OTP
	err := r.db.WithContext(ctx).
		Where("user_id = ? AND channel = ? AND is_used = false AND expires_at > ?", userID, channel, time.Now()).
		Order("created_at DESC").
		First(&otp).Error
	if err != nil {
		return nil, err
	}
	return &otp, nil
}

func (r *repository) MarkOTUsed(ctx context.Context, otpID uuid.UUID) error {
	return r.db.WithContext(ctx).Model(&OTP{}).Where("id = ?", otpID).Update("is_used", true).Error
}

func (r *repository) StoreSession(ctx context.Context, userID string, token string, expiration time.Duration) error {
	return r.redis.Set(ctx, "session:"+userID, token, expiration).Err()
}
