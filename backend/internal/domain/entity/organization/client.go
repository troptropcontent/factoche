package organization_entity

import (
	"time"

	"github.com/go-playground/validator/v10"
	shared_entity "github.com/troptropcontent/factoche/internal/domain/entity/shared"
)

type Client struct {
	ID                 int
	CompanyID          int `validate:"required"`
	Address            shared_entity.Address
	Email              string `validate:"required,email"`
	Phone              string `validate:"required,e164"` // https://en.wikipedia.org/wiki/E.164
	RegistrationNumber string `validate:"required"`
	CreatedAt          time.Time
	UpdatedAt          time.Time
	DeletedAt          time.Time
}

func (c *Client) Validate() error {
	return validator.New().Struct(c)
}
