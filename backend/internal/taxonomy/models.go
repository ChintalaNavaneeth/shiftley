package taxonomy

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Category struct {
	ID        uuid.UUID      `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	Name      string         `gorm:"uniqueIndex;not null" json:"name"`
	IsActive  bool           `gorm:"default:true" json:"is_active"`
	Skills    []Skill        `gorm:"foreignKey:CategoryID" json:"skills"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

func (Category) TableName() string {
	return "shiftley.categories"
}

type Skill struct {
	ID         uuid.UUID      `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	CategoryID uuid.UUID      `gorm:"type:uuid;index;not null" json:"category_id"`
	Name       string         `gorm:"not null" json:"name"`
	IsActive   bool           `gorm:"default:true" json:"is_active"`
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `gorm:"index" json:"-"`
}

func (Skill) TableName() string {
	return "shiftley.skills"
}
