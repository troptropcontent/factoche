package auth_usecase

import (
	"context"
	"fmt"
	"time"

	auth_repository "github.com/troptropcontent/factoche/internal/domain/repository/auth"
	"github.com/troptropcontent/factoche/pkg/jwt"
	"github.com/troptropcontent/factoche/pkg/passhash"
)

const ACCESS_TOKEN_DURATION = time.Hour * 24
const REFRESH_TOKEN_DURATION = time.Hour * 24 * 30

// LoginUseCase is the usecase for logging in
// For valid credentials, it returns the access and refresh tokens
// To avoid leaking information, it returns the same error for any credential failure
type LoginUseCase interface {
	Execute(ctx context.Context, email, password string) (accessToken, refreshToken string, err error)
}

type loginUseCase struct {
	userRepo               auth_repository.UserRepository
	refreshTokenJwtService jwt.JWT
	accessTokenJwtService  jwt.JWT
	hasher                 passhash.Passhash
}

// Returns a new LoginUseCase instance with the given dependencies
func NewLoginUseCase(userRepo auth_repository.UserRepository, accessTokenJwtService jwt.JWT, refreshTokenJwtService jwt.JWT, hasher passhash.Passhash) LoginUseCase {
	return &loginUseCase{userRepo: userRepo, accessTokenJwtService: accessTokenJwtService, refreshTokenJwtService: refreshTokenJwtService, hasher: hasher}
}

// Implements LoginUseCase logic
func (uc *loginUseCase) Execute(ctx context.Context, email, password string) (accessToken, refreshToken string, err error) {
	// 1. Get user by email
	user, err := uc.userRepo.GetByEmail(ctx, email)
	if err != nil {
		return "", "", auth_repository.ErrUserNotFound
	}

	// 2. Verify password matches
	fmt.Printf("Verify password result: %v\n", uc.hasher.VerifyPassword(user.Password, password))
	if !uc.hasher.VerifyPassword(user.Password, password) {
		return "", "", auth_repository.ErrUserNotFound // Using same error to not leak info
	}
	// 3. Generate JWT token
	accessToken, _ = uc.accessTokenJwtService.GenerateToken(fmt.Sprintf("%d", user.ID), user.Email, ACCESS_TOKEN_DURATION)
	refreshToken, _ = uc.refreshTokenJwtService.GenerateToken(fmt.Sprintf("%d", user.ID), user.Email, REFRESH_TOKEN_DURATION)

	if accessToken == "" || refreshToken == "" {
		return "", "", auth_repository.ErrUserNotFound // Using same error to not leak info
	}

	return accessToken, refreshToken, nil
}
