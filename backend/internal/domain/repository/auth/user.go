package auth_repository

import (
	"context"

	auth_entity "github.com/troptropcontent/factoche/internal/domain/entity/auth"
)

type UserRepository interface {
	Create(ctx context.Context, user *auth_entity.User) error
}
