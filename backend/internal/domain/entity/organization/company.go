package organization_entity

import (
	"time"

	"github.com/go-playground/validator/v10"
)

type Company struct {
	ID                 uint
	Name               string `validate:"required"`
	Email              string `validate:"required,email"`
	Phone              string `validate:"required"`
	AddressStreet      string `validate:"required"`
	AddressCity        string `validate:"required"`
	AddressZipCode     string `validate:"required"`
	RegistrationNumber string `validate:"required"`
	VatNumber          string
	CreatedAt          time.Time
	UpdatedAt          time.Time
	DeletedAt          time.Time
}

func (c *Company) Validate() error {
	return validator.New().Struct(c)
}
