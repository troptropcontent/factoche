package organization_entity

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	shared_entity "github.com/troptropcontent/factoche/internal/domain/entity/shared"
)

func TestClient_Validate(t *testing.T) {
	tests := []struct {
		name           string
		client         Client
		wantErrMessage string
	}{
		{
			name: "valid client",
			client: Client{
				CompanyID: 1,
				Address: shared_entity.Address{
					Street:  "15 rue de la paix",
					City:    "Paris",
					Zipcode: "75001",
				},
				Email:              "test@example.com",
				Phone:              "+1234567890",
				RegistrationNumber: "1234567890",
				CreatedAt:          time.Now(),
				UpdatedAt:          time.Now(),
			},
			wantErrMessage: "",
		},
		{
			name: "invalid email",
			client: Client{
				CompanyID: 1,
				Address: shared_entity.Address{
					Street:  "15 rue de la paix",
					City:    "Paris",
					Zipcode: "75001",
				},
				Email:              "invalid-email",
				Phone:              "+1234567890",
				RegistrationNumber: "REG123",
				CreatedAt:          time.Now(),
				UpdatedAt:          time.Now(),
			},
			wantErrMessage: "Key: 'Client.Email' Error:Field validation for 'Email' failed on the 'email' tag",
		},
		{
			name: "invalid phone",
			client: Client{
				CompanyID: 1,
				Address: shared_entity.Address{
					Street:  "15 rue de la paix",
					City:    "Paris",
					Zipcode: "75001",
				},
				Email:              "test@example.com",
				Phone:              "+129",
				RegistrationNumber: "1234567890",
				CreatedAt:          time.Now(),
				UpdatedAt:          time.Now(),
			},
			wantErrMessage: "Key: 'Client.Phone' Error:Field validation for 'Phone' failed on the 'e164' tag",
		},
		{
			name: "missing address",
			client: Client{
				CompanyID:          1,
				Email:              "test@example.com",
				Phone:              "+1234567890",
				RegistrationNumber: "1234567890",
				CreatedAt:          time.Now(),
				UpdatedAt:          time.Now(),
			},
			wantErrMessage: "Key: 'Client.Address.Street' Error:Field validation for 'Street' failed on the 'required' tag\nKey: 'Client.Address.City' Error:Field validation for 'City' failed on the 'required' tag\nKey: 'Client.Address.Zipcode' Error:Field validation for 'Zipcode' failed on the 'required' tag",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.client.Validate()
			if tt.wantErrMessage != "" {
				assert.EqualError(t, err, tt.wantErrMessage)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}
