package jwt

import (
	"crypto/rand"
	"encoding/base64"
	"errors"
	"time"

	golang_jwt "github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

const DEFAULT_JWT_SECRET_LENGTH = 32

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
			ID:        uuid.New().String(),
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

// GenerateJWTSecret generates a random base64 encoded string of the given length,
// which can be used as the secret key for the JWT.
func GenerateJWTSecret(args ...int) (string, error) {
	length := DEFAULT_JWT_SECRET_LENGTH
	if len(args) > 0 {
		length = args[0]
	}

	if length <= 0 {
		return "", errors.New("invalid length")
	}

	// Generate random bytes
	bytes := make([]byte, length)
	if _, err := rand.Read(bytes); err != nil {
		return "", err
	}

	// Convert to base64
	return base64.StdEncoding.EncodeToString(bytes), nil
}
