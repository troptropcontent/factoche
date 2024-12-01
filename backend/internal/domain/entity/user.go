package entity

import "time"

type User struct {
	ID        uint
	Email     string
	Password  string // Hashed password
	CreatedAt time.Time
	UpdatedAt time.Time
	DeletedAt time.Time
}
