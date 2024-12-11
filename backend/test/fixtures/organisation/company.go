package organization_testfixtures

import (
	organization_entity "github.com/troptropcontent/factoche/internal/domain/entity/organization"
	shared_entity "github.com/troptropcontent/factoche/internal/domain/entity/shared"
)

var Company = organization_entity.Company{
	Name:  "toto",
	Email: "toto@gmail.com",
	Phone: "+33612345667",
	Address: shared_entity.Address{
		Street:  "24 rue des coucou",
		City:    "Pau",
		Zipcode: "12345"},
	RegistrationNumber: "123",
}
