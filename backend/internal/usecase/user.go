package usecase

import (
	"context"

	"github.com/troptropcontent/factoche/internal/domain/entity"
	"github.com/troptropcontent/factoche/internal/domain/repository"
	"golang.org/x/crypto/bcrypt"
)

type UserUseCase interface {
	CreateUser(ctx context.Context, email, password string) (*entity.User, error)
}

type userUseCase struct {
	userRepo repository.UserRepository
}

func NewUserUseCase(userRepo repository.UserRepository) UserUseCase {
	return &userUseCase{userRepo: userRepo}
}

func (uc *userUseCase) CreateUser(ctx context.Context, email, password string) (*entity.User, error) {
	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	user := &entity.User{
		Email:    email,
		Password: string(hashedPassword),
	}

	if err := uc.userRepo.Create(ctx, user); err != nil {
		return nil, err
	}

	return user, nil
}
