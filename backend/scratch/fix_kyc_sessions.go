package main

import (
	"fmt"
	"log"
	"time"

	"github.com/google/uuid"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type User struct {
	ID uuid.UUID
	Role string
}

type KYCSession struct {
	ID            uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()"`
	UserID        uuid.UUID `gorm:"type:uuid;not null;index"`
	Status        string    `gorm:"type:varchar(20);default:'PENDING'"`
	MaskedAadhaar string
	CreatedAt     time.Time
	UpdatedAt     time.Time
}

func (KYCSession) TableName() string {
	return "shiftley.kyc_sessions"
}

func main() {
	dsn := "host=localhost user=postgres password=postgres dbname=shiftley port=5432 sslmode=disable"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal(err)
	}

	var users []User
	// Find employers who don't have a KYC session
	err = db.Raw(`
		SELECT u.id, u.role 
		FROM shiftley.users u
		LEFT JOIN shiftley.kyc_sessions k ON k.user_id = u.id
		WHERE u.role = 'EMPLOYER' AND k.id IS NULL
	`).Scan(&users).Error

	if err != nil {
		log.Fatal(err)
	}

	for _, user := range users {
		fmt.Printf("Creating KYC session for user %s\n", user.ID)
		session := KYCSession{
			UserID: user.ID,
			Status: "PENDING",
		}
		if err := db.Create(&session).Error; err != nil {
			fmt.Printf("Failed to create session for %s: %v\n", user.ID, err)
		}
	}
	fmt.Println("Done")
}
