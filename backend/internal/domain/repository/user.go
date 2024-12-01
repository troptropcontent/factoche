package repository

import (
	"context"

	"github.com/troptropcontent/factoche/internal/domain/entity"
)

type UserRepository interface {
	Create(ctx context.Context, user *entity.User) error
}
