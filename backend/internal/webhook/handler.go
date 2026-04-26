package webhook

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"

	"shiftley/internal/gig"
	"shiftley/pkg/utils"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type Handler struct {
	db              *gorm.DB
	razorpaySecret  string
	whatsappSecret  string
}

func NewHandler(db *gorm.DB, rzSecret, waSecret string) *Handler {
	return &Handler{
		db:             db,
		razorpaySecret: rzSecret,
		whatsappSecret: waSecret,
	}
}

// RazorpayWebhook handles POST /api/v1/webhooks/razorpay
func (h *Handler) RazorpayWebhook(c *gin.Context) {
	signature := c.GetHeader("X-Razorpay-Signature")
	body, _ := io.ReadAll(c.Request.Body)

	// 1. Verify Signature
	if !h.verifyRazorpaySignature(body, signature) {
		utils.RespondError(c, http.StatusUnauthorized, utils.ErrForbidden, "Invalid signature", nil)
		return
	}

	// 2. Parse Event
	var event struct {
		Event   string `json:"event"`
		Payload struct {
			Payment struct {
				Entity struct {
					OrderID string `json:"order_id"`
					Status  string `json:"status"`
				} `json:"entity"`
			} `json:"payment"`
		} `json:"payload"`
	}

	if err := json.Unmarshal(body, &event); err != nil {
		utils.RespondError(c, http.StatusBadRequest, utils.ErrValidation, "Invalid JSON", nil)
		return
	}

	// 3. Process Business Logic
	if event.Event == "payment.captured" {
		orderID := event.Payload.Payment.Entity.OrderID
		
		// Update Gig status to OPEN (funded)
		result := h.db.Model(&gig.Gig{}).Where("razorpay_order_id = ? AND status = ?", orderID, gig.StatusPendingPayment).
			Update("status", gig.StatusOpen)
		
		if result.Error != nil {
			fmt.Printf("[WEBHOOK ERROR] Failed to update gig for order %s: %v\n", orderID, result.Error)
		} else if result.RowsAffected > 0 {
			fmt.Printf("[WEBHOOK SUCCESS] Gig funded and live for order %s\n", orderID)
		}
	}

	c.Status(http.StatusOK)
}

// WhatsAppWebhook handles POST /api/v1/webhooks/whatsapp
func (h *Handler) WhatsAppWebhook(c *gin.Context) {
	// Meta uses X-Hub-Signature-256: sha256=<hash>
	// signature := c.GetHeader("X-Hub-Signature-256")
	body, _ := io.ReadAll(c.Request.Body)

	// 1. Verify Signature (Mocked for dev ease, implementation provided)
	/*
	if !h.verifyWhatsAppSignature(body, signature) {
		c.Status(http.StatusUnauthorized)
		return
	}
	*/

	// 2. Process Status Receipts
	fmt.Printf("[WHATSAPP WEBHOOK] Received event: %s\n", string(body))

	c.Status(http.StatusOK)
}

func (h *Handler) verifyRazorpaySignature(body []byte, signature string) bool {
	if h.razorpaySecret == "" {
		return true // Allow in mock/dev mode
	}
	mac := hmac.New(sha256.New, []byte(h.razorpaySecret))
	mac.Write(body)
	expectedSignature := hex.EncodeToString(mac.Sum(nil))
	return hmac.Equal([]byte(expectedSignature), []byte(signature))
}

func (h *Handler) verifyWhatsAppSignature(body []byte, signature string) bool {
	if h.whatsappSecret == "" {
		return true
	}
	// Meta signature format: sha256=<hash>
	if len(signature) < 7 || signature[:7] != "sha256=" {
		return false
	}
	actualHash := signature[7:]
	mac := hmac.New(sha256.New, []byte(h.whatsappSecret))
	mac.Write(body)
	expectedHash := hex.EncodeToString(mac.Sum(nil))
	return hmac.Equal([]byte(expectedHash), []byte(actualHash))
}
