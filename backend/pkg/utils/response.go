package utils

import (
	"github.com/gin-gonic/gin"
)

// SuccessResponse represents the standardized success wrapper
type SuccessResponse struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data,omitempty"`
	Meta    interface{} `json:"meta,omitempty"`
}

// ErrorDetail represents specific validation or context errors
type ErrorDetail struct {
	Code    string      `json:"code"`
	Message string      `json:"message"`
	Details []string    `json:"details,omitempty"`
}

// FailureResponse represents the standardized error wrapper
type FailureResponse struct {
	Success bool        `json:"success"`
	Error   ErrorDetail `json:"error"`
}

// RespondSuccess sends a 200 OK or similar success status with wrapped JSON
func RespondSuccess(c *gin.Context, status int, data interface{}, meta interface{}) {
	c.JSON(status, SuccessResponse{
		Success: true,
		Data:    data,
		Meta:    meta,
	})
}

// RespondError sends an error status with wrapped failure JSON
func RespondError(c *gin.Context, status int, code string, message string, details []string) {
	c.JSON(status, FailureResponse{
		Success: false,
		Error: ErrorDetail{
			Code:    code,
			Message: message,
			Details: details,
		},
	})
}

// Common Error Codes
const (
	ErrInternal        = "INTERNAL_SERVER_ERROR"
	ErrValidation      = "VALIDATION_FAILED"
	ErrUnauthorized    = "UNAUTHORIZED"
	ErrForbidden       = "FORBIDDEN"
	ErrNotFound        = "NOT_FOUND"
	ErrConflict        = "CONFLICT"
	ErrTooManyRequests = "RATE_LIMIT_EXCEEDED"
)
