package auth_usecase

import (
	"context"
	"errors"

	"github.com/troptropcontent/factoche/pkg/jwt"
)

type RefreshUseCase interface {
	Execute(ctx context.Context, refreshToken string) (accessToken string, err error)
}

type refreshUseCase struct {
	accessTokenJwtService  jwt.JWT
	refreshTokenJwtService jwt.JWT
}

func NewRefreshUseCase(accessTokenJwtService jwt.JWT, refreshTokenJwtService jwt.JWT) RefreshUseCase {
	return &refreshUseCase{accessTokenJwtService: accessTokenJwtService, refreshTokenJwtService: refreshTokenJwtService}
}

func (uc *refreshUseCase) Execute(ctx context.Context, refreshToken string) (accessToken string, err error) {

	refreshClaims, err := uc.refreshTokenJwtService.VerifyToken(refreshToken)
	if err != nil {
		return "", errors.New("invalid token")
	}

	accessToken, _ = uc.accessTokenJwtService.GenerateToken(refreshClaims.UserID, refreshClaims.Email, ACCESS_TOKEN_DURATION)

	if accessToken == "" {
		return "", errors.New("error while creating token")
	}

	return accessToken, nil
}
