package main

import (
	"fmt"
	"log"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func main() {
	dsn := "host=localhost user=postgres password=postgres dbname=shiftley port=5432 sslmode=disable"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal(err)
	}

	// Fix users who have an EmployerProfile but the wrong role
	result := db.Exec(`
		UPDATE shiftley.users 
		SET role = 'EMPLOYER' 
		WHERE id IN (SELECT user_id FROM shiftley.employer_profiles)
		AND role != 'EMPLOYER'
	`)

	if result.Error != nil {
		log.Fatal(result.Error)
	}

	fmt.Printf("Updated %d users to EMPLOYER role\n", result.RowsAffected)

	// Fix users who have a WorkerProfile but the wrong role
	result = db.Exec(`
		UPDATE shiftley.users 
		SET role = 'WORKER' 
		WHERE id IN (SELECT user_id FROM shiftley.worker_profiles)
		AND role != 'WORKER'
	`)

	if result.Error != nil {
		log.Fatal(result.Error)
	}

	fmt.Printf("Updated %d users to WORKER role\n", result.RowsAffected)
}
