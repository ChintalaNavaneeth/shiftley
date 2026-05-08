package gig

import (
	"shiftley/pkg/events"
)

const (
	EventGigCreated          = "gig.created"
	EventApplicationSubmitted = "application.submitted"
	EventApplicationAccepted  = "application.accepted"
	EventApplicationRejected  = "application.rejected"
)

// GigCreatedEvent payload
type GigCreatedEvent struct {
	events.BaseEvent
}

func NewGigCreatedEvent(gigID string, employerID string, title string) events.Event {
	return GigCreatedEvent{
		BaseEvent: events.BaseEvent{
			EventName: EventGigCreated,
			EventPayload: map[string]interface{}{
				"gig_id":      gigID,
				"employer_id": employerID,
				"title":       title,
			},
		},
	}
}

// ApplicationSubmittedEvent payload
type ApplicationSubmittedEvent struct {
	events.BaseEvent
}

func NewApplicationSubmittedEvent(appID string, gigID string, employeeID string) events.Event {
	return ApplicationSubmittedEvent{
		BaseEvent: events.BaseEvent{
			EventName: EventApplicationSubmitted,
			EventPayload: map[string]interface{}{
				"application_id": appID,
				"gig_id":         gigID,
				"employee_id":    employeeID,
			},
		},
	}
}

// ApplicationStatusChangedEvent payload
type ApplicationStatusChangedEvent struct {
	events.BaseEvent
}

func NewApplicationStatusChangedEvent(eventName string, appID string, gigID string, employeeID string) events.Event {
	return ApplicationStatusChangedEvent{
		BaseEvent: events.BaseEvent{
			EventName: eventName,
			EventPayload: map[string]interface{}{
				"application_id": appID,
				"gig_id":         gigID,
				"employee_id":    employeeID,
			},
		},
	}
}
