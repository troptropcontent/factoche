package auth_repositories

import (
	"context"

	auth_entity "github.com/troptropcontent/factoche/internal/domain/entity/auth"
	auth_repository "github.com/troptropcontent/factoche/internal/domain/repository/auth"
	auth_models "github.com/troptropcontent/factoche/internal/infrastructure/database/postgres/models/auth"
	"gorm.io/gorm"
)

type userRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) auth_repository.UserRepository {
	return &userRepository{db: db}
}

func (r *userRepository) Create(ctx context.Context, user *auth_entity.User) error {
	model := &auth_models.User{}
	model.FromEntity(user)

	result := r.db.WithContext(ctx).Create(model)
	if result.Error != nil {
		return result.Error
	}

	user.ID = model.ID
	return nil
}
