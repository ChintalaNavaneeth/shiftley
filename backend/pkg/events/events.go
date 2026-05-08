package events

import (
	"sync"
)

// Event defines the interface for all events
type Event interface {
	Name() string
	Payload() interface{}
}

// HandlerFunc is the type for event handlers
type HandlerFunc func(event Event)

// EventBus defines the interface for the event bus
type EventBus interface {
	Publish(event Event)
	Subscribe(eventName string, handler HandlerFunc)
}

// MemoryEventBus is an in-memory implementation of EventBus
type MemoryEventBus struct {
	mu       sync.RWMutex
	handlers map[string][]HandlerFunc
}

// NewMemoryEventBus creates a new MemoryEventBus
func NewMemoryEventBus() *MemoryEventBus {
	return &MemoryEventBus{
		handlers: make(map[string][]HandlerFunc),
	}
}

// Publish sends the event to all registered handlers
func (b *MemoryEventBus) Publish(event Event) {
	b.mu.RLock()
	defer b.mu.RUnlock()

	handlers, ok := b.handlers[event.Name()]
	if !ok {
		return
	}

	for _, handler := range handlers {
		// Run handlers in goroutines to avoid blocking the publisher
		go handler(event)
	}
}

// Subscribe registers a handler for a specific event
func (b *MemoryEventBus) Subscribe(eventName string, handler HandlerFunc) {
	b.mu.Lock()
	defer b.mu.Unlock()

	b.handlers[eventName] = append(b.handlers[eventName], handler)
}

// BaseEvent is a helper struct to implement the Event interface
type BaseEvent struct {
	EventName    string
	EventPayload interface{}
}

func (e BaseEvent) Name() string {
	return e.EventName
}

func (e BaseEvent) Payload() interface{} {
	return e.EventPayload
}
