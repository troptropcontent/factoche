package organization_entity

import (
	"time"

	"github.com/go-playground/validator/v10"
	shared_entity "github.com/troptropcontent/factoche/internal/domain/entity/shared"
)

type Company struct {
	ID                 uint
	Name               string `validate:"required"`
	Email              string `validate:"required,email"`
	Phone              string `validate:"required"`
	Address            shared_entity.Address
	RegistrationNumber string `validate:"required"`
	VatNumber          string
	CreatedAt          time.Time
	UpdatedAt          time.Time
	DeletedAt          time.Time
}

func (c *Company) Validate() error {
	return validator.New().Struct(c)
}
