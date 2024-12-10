package organization_entity

import (
	"testing"
	"time"

	shared_entity "github.com/troptropcontent/factoche/internal/domain/entity/shared"
)

func TestCompany_Validate(t *testing.T) {
	tests := []struct {
		name              string
		company           Company
		expectedErrorMess string
	}{
		{
			name: "valid company",
			company: Company{
				Name:  "Test Company",
				Email: "test@company.com",
				Phone: "+1234567890",
				Address: shared_entity.Address{
					Street:  "123 Test Street",
					City:    "Test City",
					Zipcode: "12345",
				},
				RegistrationNumber: "REG123456",
				VatNumber:          "VAT123456", // Optional field
				CreatedAt:          time.Now(),
				UpdatedAt:          time.Now(),
			},
			expectedErrorMess: "",
		},
		{
			name: "invalid company - missing name",
			company: Company{
				Email: "test@company.com",
				Phone: "+1234567890",
				Address: shared_entity.Address{
					Street:  "123 Test Street",
					City:    "Test City",
					Zipcode: "12345",
				},
				RegistrationNumber: "REG123456",
			},
			expectedErrorMess: "Key: 'Company.Name' Error:Field validation for 'Name' failed on the 'required' tag",
		},
		{
			name: "invalid company - invalid email",
			company: Company{
				Name:  "Test Company",
				Email: "invalid-email",
				Phone: "+1234567890",
				Address: shared_entity.Address{
					Street:  "123 Test Street",
					City:    "Test City",
					Zipcode: "12345",
				},
				RegistrationNumber: "REG123456",
			},
			expectedErrorMess: "Key: 'Company.Email' Error:Field validation for 'Email' failed on the 'email' tag",
		},
		{
			name: "invalid company - missing required fields",
			company: Company{
				Name:  "Test Company",
				Email: "test@company.com",
			},
			expectedErrorMess: "Key: 'Company.Phone' Error:Field validation for 'Phone' failed on the 'required' tag\nKey: 'Company.Address.Street' Error:Field validation for 'Street' failed on the 'required' tag\nKey: 'Company.Address.City' Error:Field validation for 'City' failed on the 'required' tag\nKey: 'Company.Address.Zipcode' Error:Field validation for 'Zipcode' failed on the 'required' tag\nKey: 'Company.RegistrationNumber' Error:Field validation for 'RegistrationNumber' failed on the 'required' tag",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.company.Validate()
			if err != nil && err.Error() != tt.expectedErrorMess {
				t.Errorf("Company.Validate() error = %v, wantErr %v", err, tt.expectedErrorMess)
			}
		})
	}
}
