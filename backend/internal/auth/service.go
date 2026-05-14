package auth

import (
	"context"
	"errors"
	"fmt"
	"os"
	"math/rand"
	"time"

	"github.com/google/uuid"
	"github.com/golang-jwt/jwt/v5"
	"gorm.io/gorm"
)

type Service interface {
	SendOTP(ctx context.Context, identifier string, channel string, role string) (string, error)
	VerifyOTP(ctx context.Context, identifier string, channel string, code string, expectedRole string) (string, string, bool, *User, error)
	RefreshToken(ctx context.Context, refreshToken string) (string, string, error)
	Logout(ctx context.Context, userID string) error
	GenerateToken(userID uuid.UUID, role string, tokenType string, expHours int) (string, error)
}

type service struct {
	repo      Repository
	jwtSecret string
}

func NewService(repo Repository, jwtSecret string) Service {
	return &service{repo: repo, jwtSecret: jwtSecret}
}

func (s *service) SendOTP(ctx context.Context, identifier string, channel string, role string) (string, error) {
	// 1. Check if user exists by either phone or email
	user, err := s.repo.GetUserByIdentifier(ctx, identifier)
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		return "", err
	}

	if user == nil {
		// Public signup is ONLY allowed for Workers and Employers
		if role != string(RoleWorker) && role != string(RoleEmployer) {
			return "", fmt.Errorf("unauthorized: %s accounts must be created by an administrator", role)
		}

		// New User Intent - we don't create the user yet, just a placeholder or tracking
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
	code := os.Getenv("FIXED_OTP")
	if code == "" {
		code = fmt.Sprintf("%06d", rand.Intn(1000000))
	}
	
	deliveryChannel := channel
	if deliveryChannel == "PHONE" {
		deliveryChannel = "WHATSAPP"
	}
	
	fmt.Printf("[MOCK OTP] Sent %s to %s via %s\n", code, identifier, deliveryChannel)

	// Store OTP in Redis (5 minute expiry)
	if err := s.repo.SetOTP(ctx, identifier, code, 5*time.Minute); err != nil {
		return "", err
	}

	// Return code so the handler can send it via WhatsApp Business API
	return code, nil
}

func (s *service) VerifyOTP(ctx context.Context, identifier string, channel string, code string, expectedRole string) (string, string, bool, *User, error) {
	user, err := s.repo.GetUserByIdentifier(ctx, identifier)
	if err != nil {
		return "", "", false, nil, err
	}

	storedCode, err := s.repo.GetOTP(ctx, identifier)
	if err != nil {
		return "", "", false, nil, errors.New("invalid or expired OTP")
	}

	if storedCode != code {
		return "", "", false, nil, errors.New("incorrect OTP")
	}

	// Mark OTP as used (delete from Redis)
	_ = s.repo.DeleteOTP(ctx, identifier)

	// Generate Tokens
	// isNewUser here means "Needs to complete onboarding"
	isNewUser := !user.IsInitialSetupComplete
	accessToken, refreshToken, err := s.generateTokenPair(user, isNewUser)
	if err != nil {
		return "", "", false, nil, err
	}

	// Store Refresh Token in Redis (7 days)
	if err := s.repo.SetRefreshToken(ctx, user.ID.String(), refreshToken, 7*24*time.Hour); err != nil {
		return "", "", false, nil, err
	}

	// Verify Role if expectedRole is provided
	if expectedRole != "" {
		// Special case: ADMIN can mean multiple sub-roles if needed, but for now we check exact or specific sets
		if expectedRole == "ADMIN" {
			if user.Role != RoleSuperAdmin && user.Role != RoleAdmin && user.Role != RoleHRAdmin {
				return "", "", false, nil, fmt.Errorf("unauthorized: account is not an administrator")
			}
		} else if string(user.Role) != expectedRole {
			return "", "", false, nil, fmt.Errorf("unauthorized: account is not a %s", expectedRole)
		}
	}

	return accessToken, refreshToken, isNewUser, user, nil
}

func (s *service) RefreshToken(ctx context.Context, refreshTokenStr string) (string, string, error) {
	// 1. Parse and validate the refresh token
	token, err := jwt.Parse(refreshTokenStr, func(token *jwt.Token) (interface{}, error) {
		return []byte(s.jwtSecret), nil
	})

	if err != nil || !token.Valid {
		return "", "", errors.New("invalid refresh token")
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok || claims["type"] != "refresh" {
		return "", "", errors.New("invalid token type")
	}

	userID := claims["sub"].(string)

	// 2. Check if this refresh token exists in Redis
	storedToken, err := s.repo.GetRefreshToken(ctx, userID)
	if err != nil || storedToken != refreshTokenStr {
		return "", "", errors.New("refresh token expired or revoked")
	}

	// 3. Get User
	user, err := s.repo.GetUserByID(ctx, userID)
	if err != nil {
		return "", "", err
	}

	// 4. Generate New Pair (Rotation)
	isNewUser := !user.IsInitialSetupComplete
	newAccessToken, newRefreshToken, err := s.generateTokenPair(user, isNewUser)
	if err != nil {
		return "", "", err
	}

	// 5. Update Redis with new Refresh Token
	if err := s.repo.SetRefreshToken(ctx, userID, newRefreshToken, 7*24*time.Hour); err != nil {
		return "", "", err
	}

	return newAccessToken, newRefreshToken, nil
}

func (s *service) generateTokenPair(user *User, isNewUser bool) (string, string, error) {
	tokenType := "session"
	if isNewUser {
		tokenType = "registration"
	}

	jti := uuid.New().String()

	// Access Token (15 minutes)
	accessClaims := jwt.MapClaims{
		"sub":  user.ID.String(),
		"role": user.Role,
		"type": tokenType,
		"jti":  jti,
		"exp":  time.Now().Add(15 * time.Minute).Unix(),
	}
	accessToken := jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims)
	accessTokenStr, err := accessToken.SignedString([]byte(s.jwtSecret))
	if err != nil {
		return "", "", err
	}

	// Refresh Token (7 days)
	refreshClaims := jwt.MapClaims{
		"sub":  user.ID.String(),
		"type": "refresh",
		"jti":  jti, // Shared JTI for rotation tracking
		"exp":  time.Now().Add(7 * 24 * time.Hour).Unix(),
	}
	refreshToken := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims)
	refreshTokenStr, err := refreshToken.SignedString([]byte(s.jwtSecret))
	if err != nil {
		return "", "", err
	}

	return accessTokenStr, refreshTokenStr, nil
}

func (s *service) Logout(ctx context.Context, userID string) error {
	// Revoke Refresh Token
	_ = s.repo.DeleteRefreshToken(ctx, userID)
	return nil
}

func (s *service) GenerateToken(userID uuid.UUID, role string, tokenType string, expHours int) (string, error) {
	claims := jwt.MapClaims{
		"sub":  userID.String(),
		"role": role,
		"type": tokenType,
		"jti":  uuid.New().String(),
		"exp":  time.Now().Add(time.Duration(expHours) * time.Hour).Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.jwtSecret))
}
