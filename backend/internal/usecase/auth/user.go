package auth_usecase

import (
	"context"

	auth_entity "github.com/troptropcontent/factoche/internal/domain/entity/auth"
	auth_repository "github.com/troptropcontent/factoche/internal/domain/repository/auth"
	"github.com/troptropcontent/factoche/pkg/passhash"
)

type UserUseCase interface {
	CreateUser(ctx context.Context, email, password string) (*auth_entity.User, error)
}

type userUseCase struct {
	userRepo auth_repository.UserRepository
	hasher   passhash.Passhash
}

func NewUserUseCase(userRepo auth_repository.UserRepository, hasher passhash.Passhash) UserUseCase {
	return &userUseCase{userRepo: userRepo, hasher: hasher}
}

func (uc *userUseCase) CreateUser(ctx context.Context, email, password string) (*auth_entity.User, error) {
	// Hash password
	hashedPassword, err := uc.hasher.HashPassword(password)
	if err != nil {
		return nil, err
	}

	user := &auth_entity.User{
		Email:    email,
		Password: string(hashedPassword),
	}

	if err := uc.userRepo.Create(ctx, user); err != nil {
		return nil, err
	}

	return user, nil
}
