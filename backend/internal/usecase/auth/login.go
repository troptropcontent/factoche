package auth_usecase

import (
	"context"
	"errors"

	auth_entity "github.com/troptropcontent/factoche/internal/domain/entity/auth"
)

type LoginUseCase interface {
	Execute(ctx context.Context, email, password string) (*auth_entity.Token, error)
}

// Domain errors
var (
	ErrInvalidCredentials = errors.New("invalid credentials")
	ErrUserNotFound       = errors.New("user not found")
	ErrUserInactive       = errors.New("user is inactive")
)
