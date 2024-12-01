package repositories

import (
	"context"

	"github.com/troptropcontent/factoche/internal/domain/entity"
	"github.com/troptropcontent/factoche/internal/domain/repository"
	"github.com/troptropcontent/factoche/internal/infrastructure/database/postgres/models"
	"gorm.io/gorm"
)

type userRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) repository.UserRepository {
	return &userRepository{db: db}
}

func (r *userRepository) Create(ctx context.Context, user *entity.User) error {
	model := &models.User{}
	model.FromEntity(user)

	result := r.db.WithContext(ctx).Create(model)
	if result.Error != nil {
		return result.Error
	}

	user.ID = model.ID
	return nil
}
