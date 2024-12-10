package organization_model

import (
	organization_entity "github.com/troptropcontent/factoche/internal/domain/entity/organization"
	shared_entity "github.com/troptropcontent/factoche/internal/domain/entity/shared"
	"gorm.io/gorm"
)

type Company struct {
	gorm.Model
	Name               string
	Email              string
	Phone              string
	AddressStreet      string
	AddressCity        string
	AddressZipCode     string
	RegistrationNumber string
	VatNumber          string
}

func (c *Company) ToEntity() *organization_entity.Company {
	return &organization_entity.Company{
		ID:    c.ID,
		Name:  c.Name,
		Email: c.Email,
		Phone: c.Phone,
		Address: shared_entity.Address{
			Street:  c.AddressStreet,
			City:    c.AddressCity,
			Zipcode: c.AddressZipCode,
		},
		RegistrationNumber: c.RegistrationNumber,
		VatNumber:          c.VatNumber,
		CreatedAt:          c.CreatedAt,
		UpdatedAt:          c.UpdatedAt,
		DeletedAt:          c.DeletedAt.Time,
	}
}

func (c *Company) FromEntity(company *organization_entity.Company) {
	c.ID = company.ID
	c.Name = company.Name
	c.Email = company.Email
	c.Phone = company.Phone
	c.AddressStreet = company.Address.Street
	c.AddressCity = company.Address.City
	c.AddressZipCode = company.Address.Zipcode
	c.RegistrationNumber = company.RegistrationNumber
	c.VatNumber = company.VatNumber
	c.CreatedAt = company.CreatedAt
	c.UpdatedAt = company.UpdatedAt
	c.DeletedAt = gorm.DeletedAt{Time: company.DeletedAt}
}
