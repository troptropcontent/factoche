package organization_entity

import (
	"testing"
	"time"
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
				Name:               "Test Company",
				Email:              "test@company.com",
				Phone:              "+1234567890",
				AddressStreet:      "123 Test Street",
				AddressCity:        "Test City",
				AddressZipCode:     "12345",
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
				Email:              "test@company.com",
				Phone:              "+1234567890",
				AddressStreet:      "123 Test Street",
				AddressCity:        "Test City",
				AddressZipCode:     "12345",
				RegistrationNumber: "REG123456",
			},
			expectedErrorMess: "Key: 'Company.Name' Error:Field validation for 'Name' failed on the 'required' tag",
		},
		{
			name: "invalid company - invalid email",
			company: Company{
				Name:               "Test Company",
				Email:              "invalid-email",
				Phone:              "+1234567890",
				AddressStreet:      "123 Test Street",
				AddressCity:        "Test City",
				AddressZipCode:     "12345",
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
			expectedErrorMess: "Key: 'Company.Phone' Error:Field validation for 'Phone' failed on the 'required' tag\nKey: 'Company.AddressStreet' Error:Field validation for 'AddressStreet' failed on the 'required' tag\nKey: 'Company.AddressCity' Error:Field validation for 'AddressCity' failed on the 'required' tag\nKey: 'Company.AddressZipCode' Error:Field validation for 'AddressZipCode' failed on the 'required' tag\nKey: 'Company.RegistrationNumber' Error:Field validation for 'RegistrationNumber' failed on the 'required' tag",
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
