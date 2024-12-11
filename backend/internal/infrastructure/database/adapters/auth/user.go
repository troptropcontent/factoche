package auth_adapters

import (
	"context"
	"errors"
	"strings"

	auth_entity "github.com/troptropcontent/factoche/internal/domain/entity/auth"
	auth_repository "github.com/troptropcontent/factoche/internal/domain/repository/auth"
	auth_models "github.com/troptropcontent/factoche/internal/infrastructure/database/postgres/models/auth"
	"gorm.io/gorm"
)

type userAdapter struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) auth_repository.UserRepository {
	return &userAdapter{db: db}
}

func (a *userAdapter) Create(ctx context.Context, user *auth_entity.User) error {
	model := &auth_models.User{}
	model.FromEntity(user)

	result := a.db.WithContext(ctx).Create(model)
	if result.Error != nil {
		if strings.Contains(result.Error.Error(), "duplicate key value violates unique constraint") {
			return auth_repository.ErrUserAlreadyExists
		}
		return result.Error
	}

	user.ID = model.ID
	return nil
}

func (a *userAdapter) GetByEmail(ctx context.Context, email string) (user *auth_entity.User, err error) {
	model := &auth_models.User{}

	result := a.db.WithContext(ctx).First(model)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, auth_repository.ErrUserNotFound
		}
		return nil, result.Error
	}

	user = model.ToEntity()
	return user, nil
}
