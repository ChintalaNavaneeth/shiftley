package notify

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"
	"time"
)

const (
	whatsappAPIBase = "https://graph.facebook.com/v18.0"
	languageCode    = "en"
)

// templateParam represents a single template body parameter.
type templateParam struct {
	Type string `json:"type"` // always "text"
	Text string `json:"text"`
}

// templateComponent represents a message component (body, header, etc.).
type templateComponent struct {
	Type       string          `json:"type"`
	Parameters []templateParam `json:"parameters"`
}

// templateMessage is the WhatsApp template object.
type templateMessage struct {
	Name       string              `json:"name"`
	Language   map[string]string   `json:"language"`
	Components []templateComponent `json:"components"`
}

// whatsappPayload is the full request body sent to the Meta Cloud API.
type whatsappPayload struct {
	MessagingProduct string          `json:"messaging_product"` // always "whatsapp"
	To               string          `json:"to"`
	Type             string          `json:"type"` // always "template"
	Template         templateMessage `json:"template"`
}

// NotifyService dispatches WhatsApp template messages via Meta's Cloud API.
// If AccessToken is empty, it runs in mock mode and logs to stdout.
type NotifyService struct {
	phoneNumberID string
	accessToken   string
	httpClient    *http.Client
	mockMode      bool
}

// NewNotifyService creates a new NotifyService.
// When accessToken is empty, the service runs in mock mode (safe for local dev).
func NewNotifyService(phoneNumberID, accessToken string) *NotifyService {
	isMock := accessToken == ""
	if isMock {
		log.Println("[NOTIFY] Running in MOCK mode — WhatsApp messages will be logged to stdout only.")
	}
	return &NotifyService{
		phoneNumberID: phoneNumberID,
		accessToken:   accessToken,
		mockMode:      isMock,
		httpClient: &http.Client{
			Timeout: 10 * time.Second,
		},
	}
}

// Send dispatches a WhatsApp template message to the given phone number.
// params are the ordered body component parameters (e.g. ["Ravi", "ABC Restaurant", "9AM"]).
// This is a fire-and-forget call — errors are logged but never returned to the caller.
func (s *NotifyService) Send(ctx context.Context, phone, templateName string, params []string) error {
	// Normalize phone: strip leading + for Meta API
	phone = strings.TrimPrefix(phone, "+")

	if s.mockMode {
		log.Printf("[NOTIFY MOCK] → Template: %s | To: +%s | Params: %v", templateName, phone, params)
		return nil
	}

	// Build the parameter list
	bodyParams := make([]templateParam, len(params))
	for i, p := range params {
		bodyParams[i] = templateParam{Type: "text", Text: p}
	}

	payload := whatsappPayload{
		MessagingProduct: "whatsapp",
		To:               phone,
		Type:             "template",
		Template: templateMessage{
			Name:     templateName,
			Language: map[string]string{"code": languageCode},
			Components: []templateComponent{
				{
					Type:       "body",
					Parameters: bodyParams,
				},
			},
		},
	}

	body, err := json.Marshal(payload)
	if err != nil {
		log.Printf("[NOTIFY ERROR] Failed to marshal payload for template %s: %v", templateName, err)
		return fmt.Errorf("notify: marshal failed: %w", err)
	}

	url := fmt.Sprintf("%s/%s/messages", whatsappAPIBase, s.phoneNumberID)
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewBuffer(body))
	if err != nil {
		log.Printf("[NOTIFY ERROR] Failed to create request for template %s: %v", templateName, err)
		return fmt.Errorf("notify: create request failed: %w", err)
	}

	req.Header.Set("Authorization", "Bearer "+s.accessToken)
	req.Header.Set("Content-Type", "application/json")

	resp, err := s.httpClient.Do(req)
	if err != nil {
		log.Printf("[NOTIFY ERROR] Failed to send template %s to +%s: %v", templateName, phone, err)
		return fmt.Errorf("notify: http request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		log.Printf("[NOTIFY ERROR] Non-2xx response (%d) for template %s to +%s", resp.StatusCode, templateName, phone)
		return fmt.Errorf("notify: api responded with status %d", resp.StatusCode)
	}

	log.Printf("[NOTIFY OK] Sent template: %s → +%s", templateName, phone)
	return nil
}

// SendAsync dispatches a notification in a separate goroutine (truly fire-and-forget).
// Use this inside HTTP handlers so the response is never delayed by WhatsApp API latency.
func (s *NotifyService) SendAsync(phone, templateName string, params []string) {
	go func() {
		if err := s.Send(context.Background(), phone, templateName, params); err != nil {
			log.Printf("[NOTIFY ASYNC ERROR] template=%s phone=%s err=%v", templateName, phone, err)
		}
	}()
}
