package organization_entity

import (
	"time"

	"github.com/go-playground/validator/v10"
)

type Member struct {
	ID        uint      `validate:"required"`
	UserID    uint      `validate:"required"`
	CompanyID uint      `validate:"required"`
	Role      string    `validate:"required"`
	CreatedAt time.Time `validate:"required"`
	UpdatedAt time.Time `validate:"required"`
	DeletedAt time.Time `validate:"required"`
}

func (m *Member) Validate() error {
	return validator.New().Struct(m)
}
