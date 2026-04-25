package middleware

import (
	"fmt"
	"net/http"
	"strings"

	"shiftley/pkg/utils"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

// RequireAuth validates the JWT token and injects claims into the context
func RequireAuth(jwtSecret string) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			utils.RespondError(c, http.StatusUnauthorized, utils.ErrUnauthorized, "Authorization header is required", nil)
			c.Abort()
			return
		}

		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
			utils.RespondError(c, http.StatusUnauthorized, utils.ErrUnauthorized, "Authorization header format must be Bearer {token}", nil)
			c.Abort()
			return
		}

		tokenString := parts[1]

		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
			}
			return []byte(jwtSecret), nil
		})

		if err != nil || !token.Valid {
			utils.RespondError(c, http.StatusUnauthorized, utils.ErrUnauthorized, "Invalid or expired token", nil)
			c.Abort()
			return
		}

		if claims, ok := token.Claims.(jwt.MapClaims); ok {
			c.Set("userID", claims["sub"])
			c.Set("userRole", claims["role"])
			c.Set("tokenType", claims["type"])
		} else {
			utils.RespondError(c, http.StatusUnauthorized, utils.ErrUnauthorized, "Failed to parse token claims", nil)
			c.Abort()
			return
		}

		c.Next()
	}
}

// RequireRoles restricts access to specific roles
func RequireRoles(roles ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
		userRole, exists := c.Get("userRole")
		if !exists {
			utils.RespondError(c, http.StatusUnauthorized, utils.ErrUnauthorized, "Unauthorized", nil)
			c.Abort()
			return
		}

		roleStr, ok := userRole.(string)
		if !ok {
			utils.RespondError(c, http.StatusForbidden, utils.ErrForbidden, "Invalid role format", nil)
			c.Abort()
			return
		}

		hasRole := false
		for _, r := range roles {
			if roleStr == r {
				hasRole = true
				break
			}
		}

		if !hasRole {
			utils.RespondError(c, http.StatusForbidden, utils.ErrForbidden, "Access denied: insufficient permissions", nil)
			c.Abort()
			return
		}

		c.Next()
	}
}
