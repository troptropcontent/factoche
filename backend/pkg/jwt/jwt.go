package jwt

import (
	"errors"
	"time"

	golang_jwt "github.com/golang-jwt/jwt/v5"
)

type JWT struct {
	secretKey string
}

type Claims struct {
	UserID string `json:"user_id"`
	Email  string `json:"email"`
	golang_jwt.RegisteredClaims
}

func NewJWT(secretKey string) *JWT {
	return &JWT{secretKey: secretKey}
}

func (j *JWT) GenerateToken(userID, email string, duration time.Duration) (string, error) {
	claims := &Claims{
		UserID: userID,
		Email:  email,
		RegisteredClaims: golang_jwt.RegisteredClaims{
			ExpiresAt: golang_jwt.NewNumericDate(time.Now().Add(duration)),
			IssuedAt:  golang_jwt.NewNumericDate(time.Now()),
		},
	}

	token := golang_jwt.NewWithClaims(golang_jwt.SigningMethodHS256, claims)

	signedToken, err := token.SignedString([]byte(j.secretKey))

	if err != nil {
		return "", err
	}

	return signedToken, nil
}

func (j *JWT) VerifyToken(token string) (*Claims, error) {
	claims := &Claims{}
	parsedToken, err := golang_jwt.ParseWithClaims(token, claims, func(token *golang_jwt.Token) (interface{}, error) {
		return []byte(j.secretKey), nil
	})

	if err != nil {
		return nil, err
	}

	if !parsedToken.Valid {
		return nil, errors.New("invalid token")
	}

	return claims, nil
}
