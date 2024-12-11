package auth_adapters

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/troptropcontent/factoche/internal/config"
	auth_entity "github.com/troptropcontent/factoche/internal/domain/entity/auth"
	auth_repository "github.com/troptropcontent/factoche/internal/domain/repository/auth"
	"github.com/troptropcontent/factoche/internal/infrastructure/database/postgres"
	auth_models "github.com/troptropcontent/factoche/internal/infrastructure/database/postgres/models/auth"
	"gorm.io/gorm"
)

func TestUserRepository_Create(t *testing.T) {
	tests := []struct {
		name    string
		user    *auth_entity.User
		before  func(*gorm.DB)
		wantErr error
	}{
		{
			name: "successful creation",
			user: &auth_entity.User{
				Email:    "test@example.com",
				Password: "hashedpassword",
			},
			wantErr: nil,
		},
		{
			name: "duplicate email error",
			user: &auth_entity.User{
				Email:    "existing@example.com",
				Password: "hashedpassword",
			},
			before: func(db *gorm.DB) {
				repo := NewUserRepository(db)
				repo.Create(context.Background(), &auth_entity.User{
					Email:    "existing@example.com",
					Password: "hashedpassword",
				})
			},
			wantErr: auth_repository.ErrUserAlreadyExists,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			withTransaction(t, func(transaction *gorm.DB) {
				if tt.before != nil {
					tt.before(transaction)
				}

				repo := NewUserRepository(transaction)
				err := repo.Create(context.Background(), tt.user)

				if tt.wantErr != nil {
					assert.ErrorIs(t, err, tt.wantErr)
				} else {
					assert.NoError(t, err)
					assert.NotZero(t, tt.user.ID) // Verify ID was set

					// Verify user was actually created in database
					var savedUser auth_models.User
					result := transaction.First(&savedUser, tt.user.ID)
					assert.NoError(t, result.Error)
					assert.Equal(t, tt.user.Email, savedUser.Email)
				}
			})
		})
	}
}

func TestUserRepository_GetByEmail(t *testing.T) {

	tests := []struct {
		name          string
		before        func(*gorm.DB)
		email         string
		expectedUser  *auth_entity.User
		expectedError error
	}{
		{
			name: "successful retrieval",
			before: func(transaction *gorm.DB) {
				repo := NewUserRepository(transaction)
				repo.Create(context.Background(), &auth_entity.User{
					Email:    "existing@example.com",
					Password: "hashedpassword",
				})
			},
			email: "existing@example.com",
			expectedUser: &auth_entity.User{
				Email:    "existing@example.com",
				Password: "hashedpassword",
			},
			expectedError: nil,
		},
		{
			name:          "user not found",
			email:         "nonexistent@example.com",
			expectedUser:  nil,
			expectedError: auth_repository.ErrUserNotFound,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			withTransaction(t, func(transaction *gorm.DB) {
				if tt.before != nil {
					tt.before(transaction)
				}

				repo := NewUserRepository(transaction)

				// Execute
				user, err := repo.GetByEmail(context.Background(), tt.email)

				// Assert
				if tt.expectedError != nil {
					assert.ErrorIs(t, err, tt.expectedError)
					assert.Nil(t, user)
				} else {
					assert.NoError(t, err)
					assert.NotNil(t, user)
					assert.Equal(t, tt.expectedUser.Email, user.Email)
					assert.Equal(t, tt.expectedUser.Password, user.Password)
				}
			})
		})
	}
}

func withTransaction(t *testing.T, fn func(db *gorm.DB)) {
	config := config.NewConfig()
	connection, err := postgres.NewConnection(config.DB())
	if err != nil {
		t.Fatalf("failed to connect database: %v", err)
	}

	transaction := connection.Begin()
	defer transaction.Rollback()

	fn(transaction)
}
