package repositories

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/troptropcontent/factoche/internal/config"
	"github.com/troptropcontent/factoche/internal/domain/entity"
	"github.com/troptropcontent/factoche/internal/infrastructure/database/postgres"
	"github.com/troptropcontent/factoche/internal/infrastructure/database/postgres/models"
	"gorm.io/gorm"
)

func TestUserRepository_Create(t *testing.T) {
	tests := []struct {
		name    string
		user    *entity.User
		before  func(*gorm.DB)
		wantErr bool
	}{
		{
			name: "successful creation",
			user: &entity.User{
				Email:    "test@example.com",
				Password: "hashedpassword",
			},
			wantErr: false,
		},
		{
			name: "duplicate email error",
			user: &entity.User{
				Email:    "existing@example.com",
				Password: "hashedpassword",
			},
			before: func(db *gorm.DB) {
				repo := NewUserRepository(db)
				repo.Create(context.Background(), &entity.User{
					Email:    "existing@example.com",
					Password: "hashedpassword",
				})
			},
			wantErr: true,
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

				if tt.wantErr {
					assert.Error(t, err)
				} else {
					assert.NoError(t, err)
					assert.NotZero(t, tt.user.ID) // Verify ID was set

					// Verify user was actually created in database
					var savedUser models.User
					result := transaction.First(&savedUser, tt.user.ID)
					assert.NoError(t, result.Error)
					assert.Equal(t, tt.user.Email, savedUser.Email)
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
