package organization_testfixtures

import (
	organization_entity "github.com/troptropcontent/factoche/internal/domain/entity/organization"
	shared_entity "github.com/troptropcontent/factoche/internal/domain/entity/shared"
)

func NewClient(company_id uint, overrides ...func(*organization_entity.Client)) *organization_entity.Client {
	client := &organization_entity.Client{
		ID:    1,
		Email: "client@test.com",
		Phone: "+33123456789",
		Address: shared_entity.Address{
			Street:  "123 Test Street",
			City:    "Test City",
			Zipcode: "12345",
		},
		RegistrationNumber: "123",
		CompanyID:          company_id,
	}

	for _, override := range overrides {
		override(client)
	}

	return client
}
