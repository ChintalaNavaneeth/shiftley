package auth

import (
	"context"
	"errors"
	"fmt"
	"math/rand"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"gorm.io/gorm"
)

type Service interface {
	SendOTP(ctx context.Context, identifier string, channel string, role string) (string, error)
	VerifyOTP(ctx context.Context, identifier string, channel string, code string) (string, bool, *User, error)
}

type service struct {
	repo      Repository
	jwtSecret string
}

func NewService(repo Repository, jwtSecret string) Service {
	return &service{repo: repo, jwtSecret: jwtSecret}
}

func (s *service) SendOTP(ctx context.Context, identifier string, channel string, role string) (string, error) {
	// 1. Check if user exists, if not create a placeholder or just use the intent
	user, err := s.repo.GetUserByPhone(ctx, identifier)
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		return "", err
	}

	if user == nil {
		// New User Intent - we don't create the user yet, just a placeholder or tracking
		// For now, let's create a minimal user with status unverified
		user = &User{
			PhoneNumber: identifier,
			Email:       fmt.Sprintf("%s@temp.shiftley.in", identifier), // Placeholder
			FullName:    "New User",
			Role:        UserRole(role),
			IsVerified:  false,
		}
		if err := s.repo.CreateUser(ctx, user); err != nil {
			return "", err
		}
	}

	// 2. Generate 6-digit OTP
	code := fmt.Sprintf("%06d", rand.Intn(1000000))
	
	deliveryChannel := channel
	if deliveryChannel == "PHONE" {
		deliveryChannel = "WHATSAPP"
	}
	
	fmt.Printf("[MOCK OTP] Sent %s to %s via %s\n", code, identifier, deliveryChannel)

	// Store OTP in DB
	otp := &OTP{
		UserID:    user.ID,
		Channel:   deliveryChannel,
		Code:      code,
		ExpiresAt: time.Now().Add(5 * time.Minute),
	}

	if err := s.repo.CreateOTP(ctx, otp); err != nil {
		return "", err
	}

	// Return code so the handler can send it via WhatsApp Business API
	return code, nil
}

func (s *service) VerifyOTP(ctx context.Context, identifier string, channel string, code string) (string, bool, *User, error) {
	user, err := s.repo.GetUserByPhone(ctx, identifier)
	if err != nil {
		return "", false, nil, err
	}

	deliveryChannel := channel
	if deliveryChannel == "PHONE" {
		deliveryChannel = "WHATSAPP"
	}

	otp, err := s.repo.GetLatestOTP(ctx, user.ID, deliveryChannel)
	if err != nil {
		return "", false, nil, errors.New("invalid or expired OTP")
	}

	if otp.Code != code {
		return "", false, nil, errors.New("incorrect OTP")
	}

	// Mark OTP as used
	if err := s.repo.MarkOTUsed(ctx, otp.ID); err != nil {
		return "", false, nil, err
	}

	// Generate JWT
	isNewUser := !user.IsVerified
	tokenType := "session"
	if isNewUser {
		tokenType = "registration"
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub":  user.ID.String(),
		"role": user.Role,
		"type": tokenType,
		"exp":  time.Now().Add(24 * time.Hour).Unix(),
	})

	tokenString, err := token.SignedString([]byte(s.jwtSecret))
	if err != nil {
		return "", false, nil, err
	}

	return tokenString, isNewUser, user, nil
}
