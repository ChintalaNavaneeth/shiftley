package cs

import (
	"time"

	"github.com/google/uuid"
)

type AccountNote struct {
	ID        uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	UserID    uuid.UUID `gorm:"type:uuid;not null;index" json:"user_id"`
	AgentID   uuid.UUID `gorm:"type:uuid;not null;index" json:"agent_id"`
	Category  string    `gorm:"type:varchar(50);not null" json:"category"`
	Note      string    `gorm:"type:text;not null" json:"note"`
	CreatedAt time.Time `json:"created_at"`
}

func (AccountNote) TableName() string {
	return "shiftley.account_notes"
}
