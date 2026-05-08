package gig

import (
	"fmt"
	"shiftley/internal/auth"
	"shiftley/pkg/events"
	"shiftley/pkg/notify"

	"gorm.io/gorm"
)

// RegisterListeners wires up gig-related events to their handlers
func RegisterListeners(bus events.EventBus, db *gorm.DB, notifySvc *notify.NotifyService) {
	// 1. Handle Gig Created
	bus.Subscribe(EventGigCreated, func(event events.Event) {
		payload := event.Payload().(map[string]interface{})
		fmt.Printf("[EVENT] Gig Created: %s by Employer %s\n", payload["title"], payload["employer_id"])
		// Future: Notify matching workers
	})

	// 2. Handle Application Submitted
	bus.Subscribe(EventApplicationSubmitted, func(event events.Event) {
		payload := event.Payload().(map[string]interface{})
		gigID := payload["gig_id"].(string)
		employeeID := payload["employee_id"].(string)

		var g Gig
		var worker auth.User
		var employer auth.User

		if err := db.First(&g, "id = ?", gigID).Error; err != nil {
			return
		}
		if err := db.First(&worker, "id = ?", employeeID).Error; err != nil {
			return
		}
		if err := db.First(&employer, "id = ?", g.EmployerID).Error; err != nil {
			return
		}

		// Notify Employer
		fmt.Printf("[EVENT] New Application for Gig: %s by Worker: %s\n", g.Title, worker.FullName)
		notifySvc.SendNewApplicationReceived(employer.PhoneNumber, employer.FullName, worker.FullName, g.Title)
	})

	// 3. Handle Application Accepted
	bus.Subscribe(EventApplicationAccepted, func(event events.Event) {
		payload := event.Payload().(map[string]interface{})
		gigID := payload["gig_id"].(string)
		employeeID := payload["employee_id"].(string)

		var g Gig
		var worker auth.User

		if err := db.First(&g, "id = ?", gigID).Error; err != nil {
			return
		}
		if err := db.First(&worker, "id = ?", employeeID).Error; err != nil {
			return
		}

		// Notify Worker
		fmt.Printf("[EVENT] Application Accepted for Gig: %s for Worker: %s\n", g.Title, worker.FullName)
		notifySvc.SendApplicationAccepted(worker.PhoneNumber, worker.FullName, g.Title, "Employer")
	})

	// 4. Handle Application Rejected
	bus.Subscribe(EventApplicationRejected, func(event events.Event) {
		payload := event.Payload().(map[string]interface{})
		gigID := payload["gig_id"].(string)
		employeeID := payload["employee_id"].(string)

		var g Gig
		var worker auth.User

		if err := db.First(&g, "id = ?", gigID).Error; err != nil {
			return
		}
		if err := db.First(&worker, "id = ?", employeeID).Error; err != nil {
			return
		}

		// Notify Worker
		fmt.Printf("[EVENT] Application Rejected for Gig: %s for Worker: %s\n", g.Title, worker.FullName)
		notifySvc.SendApplicationRejected(worker.PhoneNumber, worker.FullName, g.Title)
	})
}
