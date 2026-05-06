package auth

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"
	"gorm.io/gorm"
)

type Repository interface {
	GetUserByIdentifier(ctx context.Context, identifier string) (*User, error)
	GetUserByPhone(ctx context.Context, phone string) (*User, error)
	CreateUser(ctx context.Context, user *User) error
	CreateOTP(ctx context.Context, otp *OTP) error
	GetLatestOTP(ctx context.Context, userID uuid.UUID, channel string) (*OTP, error)
	MarkOTUsed(ctx context.Context, otpID uuid.UUID) error
	StoreSession(ctx context.Context, userID string, token string, expiration time.Duration) error
	BlacklistUser(ctx context.Context, userID string, expiration time.Duration) error
	SetOTP(ctx context.Context, identifier string, code string, expiration time.Duration) error
	GetOTP(ctx context.Context, identifier string) (string, error)
	DeleteOTP(ctx context.Context, identifier string) error
	SetRefreshToken(ctx context.Context, userID string, token string, expiration time.Duration) error
	GetRefreshToken(ctx context.Context, userID string) (string, error)
	DeleteRefreshToken(ctx context.Context, userID string) error
}

type repository struct {
	db    *gorm.DB
	redis *redis.Client
}

func NewRepository(db *gorm.DB, redis *redis.Client) Repository {
	return &repository{db: db, redis: redis}
}

func (r *repository) GetUserByIdentifier(ctx context.Context, identifier string) (*User, error) {
	var user User
	err := r.db.WithContext(ctx).Where("email = ? OR phone_number = ?", identifier, identifier).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
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

func (r *repository) BlacklistUser(ctx context.Context, userID string, expiration time.Duration) error {
	return r.redis.Set(ctx, "blacklist:"+userID, "revoked", expiration).Err()
}

func (r *repository) SetOTP(ctx context.Context, identifier string, code string, expiration time.Duration) error {
	return r.redis.Set(ctx, "otp:"+identifier, code, expiration).Err()
}

func (r *repository) GetOTP(ctx context.Context, identifier string) (string, error) {
	return r.redis.Get(ctx, "otp:"+identifier).Result()
}

func (r *repository) DeleteOTP(ctx context.Context, identifier string) error {
	return r.redis.Del(ctx, "otp:"+identifier).Err()
}

func (r *repository) SetRefreshToken(ctx context.Context, userID string, token string, expiration time.Duration) error {
	return r.redis.Set(ctx, "refresh_token:"+userID, token, expiration).Err()
}

func (r *repository) GetRefreshToken(ctx context.Context, userID string) (string, error) {
	return r.redis.Get(ctx, "refresh_token:"+userID).Result()
}

func (r *repository) DeleteRefreshToken(ctx context.Context, userID string) error {
	return r.redis.Del(ctx, "refresh_token:"+userID).Err()
}
