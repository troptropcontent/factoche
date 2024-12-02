package entity

import (
	"time"

	"github.com/go-playground/validator/v10"
)

type User struct {
	ID        uint
	Email     string `validate:"required,email"`
	Password  string `validate:"required"`
	CreatedAt time.Time
	UpdatedAt time.Time
	DeletedAt time.Time
}

func (u *User) Validate() error {
	return validator.New().Struct(u)
}
