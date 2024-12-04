package auth_repository

import (
	"context"
	"errors"

	auth_entity "github.com/troptropcontent/factoche/internal/domain/entity/auth"
)

var (
	ErrUserNotFound      = errors.New("user not found")      // Raised when a user is not found
	ErrUserAlreadyExists = errors.New("user already exists") // Raised when creating a user with an existing email
)

type UserRepository interface {
	Create(ctx context.Context, user *auth_entity.User) error
	GetByEmail(ctx context.Context, email string) (user *auth_entity.User, err error)
}
