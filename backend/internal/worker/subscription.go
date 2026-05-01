package worker

import (
	"fmt"
	"log"
	"time"

	"shiftley/internal/employer"
	"gorm.io/gorm"
)

type SubscriptionWorker struct {
	db *gorm.DB
}

func NewSubscriptionWorker(db *gorm.DB) *SubscriptionWorker {
	return &SubscriptionWorker{db: db}
}

func (w *SubscriptionWorker) Start() {
	// Updated to 1 hour for better precision with zero resource overhead
	ticker := time.NewTicker(1 * time.Hour)
	log.Println("[WORKER] Subscription Background Worker started (Interval: 1h)")

	go func() {
		for range ticker.C {
			w.ProcessExpirations()
		}
	}()
}

func (w *SubscriptionWorker) ProcessExpirations() {
	var expiredSubs []employer.Subscription
	now := time.Now()

	// Find active subscriptions that have passed their expiry date
	// We use shiftley schema prefix if necessary, but GORM model should handle it
	err := w.db.Where("status = ? AND expires_at < ?", "ACTIVE", now).Find(&expiredSubs).Error
	if err != nil {
		log.Printf("[WORKER ERROR] Failed to fetch expired subscriptions: %v", err)
		return
	}

	if len(expiredSubs) == 0 {
		return
	}

	log.Printf("[WORKER] Found %d expired subscriptions. Processing...", len(expiredSubs))

	for _, sub := range expiredSubs {
		// Update status to EXPIRED
		w.db.Model(&sub).Update("status", "EXPIRED")
		
		// Log Mock WhatsApp Notification
		// In a real app, we would call notifySvc.SendWhatsApp(...)
		fmt.Printf("[NOTIFY MOCK] TO Employer: %s | Message: Your Shiftley subscription has expired. Access to posting new gigs is now restricted. Please renew to continue.\n", sub.EmployerID)
	}
}
