package organization_model

import (
	organization_entity "github.com/troptropcontent/factoche/internal/domain/entity/organization"
	shared_entity "github.com/troptropcontent/factoche/internal/domain/entity/shared"
	"gorm.io/gorm"
)

type Client struct {
	gorm.Model
	CompanyID          uint
	AddressStreet      string
	AddressCity        string
	AddressZipcode     string
	Email              string
	Phone              string
	RegistrationNumber string
}

func (c *Client) ToEntity() organization_entity.Client {
	return organization_entity.Client{
		ID:        c.ID,
		CompanyID: c.CompanyID,
		Address: shared_entity.Address{
			Street:  c.AddressStreet,
			City:    c.AddressCity,
			Zipcode: c.AddressZipcode,
		},
		Email:              c.Email,
		Phone:              c.Phone,
		RegistrationNumber: c.RegistrationNumber,
		CreatedAt:          c.CreatedAt,
		UpdatedAt:          c.UpdatedAt,
		DeletedAt:          c.DeletedAt.Time,
	}
}

func (model *Client) FromEntity(entity *organization_entity.Client) {
	model.ID = entity.ID
	model.CompanyID = entity.CompanyID
	model.AddressStreet = entity.Address.Street
	model.AddressZipcode = entity.Address.Zipcode
	model.AddressCity = entity.Address.City
	model.Email = entity.Email
	model.Phone = entity.Phone
	model.RegistrationNumber = entity.RegistrationNumber
	model.CreatedAt = entity.CreatedAt
	model.UpdatedAt = entity.UpdatedAt
	model.DeletedAt = gorm.DeletedAt{Time: entity.DeletedAt}
}
