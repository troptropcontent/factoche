package auth_models

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	auth_entity "github.com/troptropcontent/factoche/internal/domain/entity/auth"
	"gorm.io/gorm"
)

func TestUser_ToEntity(t *testing.T) {
	userEmail := "test@example.com"
	userPassword := "hashedpassword"
	createdAt := time.Date(2024, 1, 1, 12, 0, 0, 0, time.UTC)
	updatedAt := time.Date(2024, 1, 2, 12, 0, 0, 0, time.UTC)
	deletedAt := time.Date(2024, 1, 3, 12, 0, 0, 0, time.UTC)

	tests := []struct {
		name     string
		input    User
		expected auth_entity.User
	}{
		{
			name: "standard case with all fields",
			input: User{
				Model: gorm.Model{
					ID:        1,
					CreatedAt: createdAt,
					UpdatedAt: updatedAt,
					DeletedAt: gorm.DeletedAt{
						Time:  deletedAt,
						Valid: true,
					},
				},
				Email:    userEmail,
				Password: userPassword,
			},
			expected: auth_entity.User{
				ID:        1,
				Email:     userEmail,
				Password:  userPassword,
				CreatedAt: createdAt,
				UpdatedAt: updatedAt,
				DeletedAt: deletedAt,
			},
		},
		{
			name: "zero values",
			input: User{
				Model: gorm.Model{},
				Email: "",
			},
			expected: auth_entity.User{
				ID:        0,
				Email:     "",
				Password:  "",
				CreatedAt: time.Time{},
				UpdatedAt: time.Time{},
				DeletedAt: time.Time{},
			},
		},
		{
			name: "special characters in email",
			input: User{
				Model: gorm.Model{ID: 1},
				Email: "test+special@example.com!#$%&'*+-/=?^_`{|}~",
			},
			expected: auth_entity.User{
				ID:    1,
				Email: "test+special@example.com!#$%&'*+-/=?^_`{|}~",
			},
		},
		{
			name: "very long strings",
			input: User{
				Model:    gorm.Model{ID: 1},
				Email:    string(make([]byte, 255)),  // Max length email
				Password: string(make([]byte, 1024)), // Very long password
			},
			expected: auth_entity.User{
				ID:       1,
				Email:    string(make([]byte, 255)),
				Password: string(make([]byte, 1024)),
			},
		},
		{
			name: "non-valid deleted at",
			input: User{
				Model: gorm.Model{
					DeletedAt: gorm.DeletedAt{Valid: false},
				},
			},
			expected: auth_entity.User{
				DeletedAt: time.Time{},
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := tt.input.ToEntity()
			assert.Equal(t, tt.expected.ID, result.ID)
			assert.Equal(t, tt.expected.Email, result.Email)
			assert.Equal(t, tt.expected.Password, result.Password)
			assert.Equal(t, tt.expected.CreatedAt, result.CreatedAt)
			assert.Equal(t, tt.expected.UpdatedAt, result.UpdatedAt)
			assert.Equal(t, tt.expected.DeletedAt, result.DeletedAt)
		})
	}
}

func TestUser_FromEntity(t *testing.T) {
	userID := uint(1)
	userEmail := "test@example.com"
	userPassword := "hashedpassword"
	createdAt := time.Date(2024, 1, 1, 12, 0, 0, 0, time.UTC)
	updatedAt := time.Date(2024, 1, 2, 12, 0, 0, 0, time.UTC)
	deletedAt := time.Date(2024, 1, 3, 12, 0, 0, 0, time.UTC)

	tests := []struct {
		name     string
		input    auth_entity.User
		expected User
	}{
		{
			name: "standard case with all fields",
			input: auth_entity.User{
				ID:        userID,
				Email:     userEmail,
				Password:  userPassword,
				CreatedAt: createdAt,
				UpdatedAt: updatedAt,
				DeletedAt: deletedAt,
			},
			expected: User{
				Model: gorm.Model{
					ID: 1,
				},
				Email:    userEmail,
				Password: userPassword,
			},
		},
		{
			name:  "zero values",
			input: auth_entity.User{},
			expected: User{
				Model:    gorm.Model{},
				Email:    "",
				Password: "",
			},
		},
		{
			name: "special characters in email",
			input: auth_entity.User{
				ID:    1,
				Email: "test+special@example.com!#$%&'*+-/=?^_`{|}~",
			},
			expected: User{
				Model: gorm.Model{ID: 1},
				Email: "test+special@example.com!#$%&'*+-/=?^_`{|}~",
			},
		},
		{
			name: "very long strings",
			input: auth_entity.User{
				ID:       1,
				Email:    string(make([]byte, 255)),  // Max length email
				Password: string(make([]byte, 1024)), // Very long password
			},
			expected: User{
				Model:    gorm.Model{ID: 1},
				Email:    string(make([]byte, 255)),
				Password: string(make([]byte, 1024)),
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var result User
			result.FromEntity(&tt.input)
			assert.Equal(t, tt.expected.ID, result.ID)
			assert.Equal(t, tt.expected.Email, result.Email)
			assert.Equal(t, tt.expected.Password, result.Password)
		})
	}
}
