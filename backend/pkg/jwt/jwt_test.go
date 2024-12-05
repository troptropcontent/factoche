package jwt

import (
	"encoding/base64"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
)

func Test_JWT_GenerateToken(t *testing.T) {
	// Test setup
	jwt := NewJWT("test-secret-key")

	tests := []struct {
		name     string
		userID   string
		email    string
		duration time.Duration
		wantErr  bool
	}{
		{
			name:     "valid inputs",
			userID:   "123",
			email:    "test@example.com",
			duration: time.Hour,
			wantErr:  false,
		},
		{
			name:     "empty userID",
			userID:   "",
			email:    "test@example.com",
			duration: time.Hour,
			wantErr:  false,
		},
		{
			name:     "empty email",
			userID:   "123",
			email:    "",
			duration: time.Hour,
			wantErr:  false,
		},
		{
			name:     "zero duration",
			userID:   "123",
			email:    "test@example.com",
			duration: 0,
			wantErr:  false,
		},
		{
			name:     "very long duration",
			userID:   "123",
			email:    "test@example.com",
			duration: time.Hour * 24 * 365, // 1 year
			wantErr:  false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			token, err := jwt.GenerateToken(tt.userID, tt.email, tt.duration)

			if (err != nil) != tt.wantErr {
				t.Errorf("GenerateToken() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			if !tt.wantErr {
				if token == "" {
					t.Error("GenerateToken() returned empty token")
				}

				// Verify token has three parts (header.payload.signature)
				parts := strings.Split(token, ".")
				if len(parts) != 3 {
					t.Errorf("GenerateToken() token has %d parts, want 3", len(parts))
				}
			}
		})
	}

	// Test UUID uniqueness
	t.Run("unique token IDs", func(t *testing.T) {
		// Generate multiple tokens with same inputs
		tokenCount := 5
		tokenIDs := make(map[string]bool)

		for i := 0; i < tokenCount; i++ {
			token, err := jwt.GenerateToken("123", "test@example.com", time.Hour)
			if err != nil {
				t.Fatalf("GenerateToken() error = %v", err)
			}

			// Parse token to extract claims
			claims, err := jwt.VerifyToken(token)
			if err != nil {
				t.Fatalf("Failed to parse token: %v", err)
			}

			// Check if ID already exists
			if tokenIDs[claims.ID] {
				t.Errorf("Duplicate token ID generated: %s", claims.ID)
			}
			tokenIDs[claims.ID] = true

			// Verify ID is valid UUID
			_, err = uuid.Parse(claims.ID)
			if err != nil {
				t.Errorf("Invalid UUID generated: %s", claims.ID)
			}
		}
	})
}

func Test_JWT_VerifyToken(t *testing.T) {
	// Test setup
	jwt := NewJWT("test-secret-key")
	wrongJWT := NewJWT("wrong-secret-key")
	userID := "123"
	email := "test@example.com"
	duration := time.Hour

	tests := []struct {
		name    string
		setup   func() string
		jwt     *JWT
		wantErr bool
		expect  *Claims
	}{
		{
			name: "valid token",
			setup: func() string {
				token, _ := jwt.GenerateToken(userID, email, duration)
				return token
			},
			jwt:     &jwt,
			wantErr: false,
			expect: &Claims{
				UserID: userID,
				Email:  email,
			},
		},
		{
			name: "invalid token format",
			setup: func() string {
				return "invalid.token.string"
			},
			jwt:     &jwt,
			wantErr: true,
		},
		{
			name: "expired token",
			setup: func() string {
				token, _ := jwt.GenerateToken(userID, email, -time.Hour)
				return token
			},
			jwt:     &jwt,
			wantErr: true,
		},
		{
			name: "malformed token",
			setup: func() string {
				return "header.payload" // missing signature part
			},
			jwt:     &jwt,
			wantErr: true,
		},
		{
			name: "empty token",
			setup: func() string {
				return ""
			},
			jwt:     &jwt,
			wantErr: true,
		},
		{
			name: "wrong secret key",
			setup: func() string {
				token, _ := jwt.GenerateToken(userID, email, duration)
				return token
			},
			jwt:     &wrongJWT,
			wantErr: true,
		},
		{
			name: "token with special characters",
			setup: func() string {
				token, _ := jwt.GenerateToken("123!@#$%^&*()", "test+special@example.com", duration)
				return token
			},
			jwt:     &jwt,
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			token := tt.setup()
			jwtService := *tt.jwt
			claims, err := jwtService.VerifyToken(token)

			if (err != nil) != tt.wantErr {
				t.Errorf("VerifyToken() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			if !tt.wantErr && tt.expect != nil {

				// Verify claims content
				if claims.UserID != tt.expect.UserID {
					t.Errorf("VerifyToken() UserID = %s, want %s", claims.UserID, tt.expect.UserID)
				}
				if claims.Email != tt.expect.Email {
					t.Errorf("VerifyToken() Email = %s, want %s", claims.Email, tt.expect.Email)
				}

				// Verify expiration time
				if claims.ExpiresAt.Time.Before(time.Now()) {
					t.Error("VerifyToken() token is expired")
				}

				// Verify issued at time
				if claims.IssuedAt.Time.After(time.Now()) {
					t.Error("VerifyToken() issued at time is in the future")
				}
			}
		})
	}
}

func Test_JWT_DifferentSecretKeys(t *testing.T) {
	// Test different secret key lengths and characters
	secrets := []string{
		"short",
		"very-long-secret-key-that-is-more-than-32-characters",
		"secret-with-special-chars-!@#$%^&*()",
		"1234567890", // numeric only
		"     ",      // spaces only
	}

	for _, secret := range secrets {
		t.Run("secret: "+secret, func(t *testing.T) {
			jwt := NewJWT(secret)
			token, err := jwt.GenerateToken("123", "test@example.com", time.Hour)

			if err != nil {
				t.Errorf("GenerateToken() error = %v with secret: %s", err, secret)
				return
			}

			claims, err := jwt.VerifyToken(token)
			if err != nil {
				t.Errorf("VerifyToken() error = %v with secret: %s", err, secret)
				return
			}

			if claims.UserID != "123" || claims.Email != "test@example.com" {
				t.Error("Claims do not match original values")
			}
		})
	}
}

func Test_GenerateJWTSecret(t *testing.T) {
	t.Run("DefaultLength", func(t *testing.T) {
		secret, err := GenerateJWTSecret()
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}

		decoded, err := base64.StdEncoding.DecodeString(secret)
		if err != nil {
			t.Fatalf("expected valid base64 string, got error: %v", err)
		}

		if len(decoded) != DEFAULT_JWT_SECRET_LENGTH {
			t.Errorf("expected length %d, got %d", DEFAULT_JWT_SECRET_LENGTH, len(decoded))
		}
	})

	t.Run("CustomLength", func(t *testing.T) {
		customLength := 64
		secret, err := GenerateJWTSecret(customLength)
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}

		decoded, err := base64.StdEncoding.DecodeString(secret)
		if err != nil {
			t.Fatalf("expected valid base64 string, got error: %v", err)
		}

		if len(decoded) != customLength {
			t.Errorf("expected length %d, got %d", customLength, len(decoded))
		}
	})

	t.Run("InvalidLength", func(t *testing.T) {
		_, err := GenerateJWTSecret(-1)
		assert.Error(t, err)
	})

	t.Run("VeryLongLength", func(t *testing.T) {
		veryLongLength := 1024 * 1024 // 1MB
		secret, err := GenerateJWTSecret(veryLongLength)
		if err != nil {
			t.Fatalf("expected no error for large length, got %v", err)
		}

		decoded, err := base64.StdEncoding.DecodeString(secret)
		if err != nil {
			t.Fatalf("expected valid base64 string, got error: %v", err)
		}

		if len(decoded) != veryLongLength {
			t.Errorf("expected length %d, got %d", veryLongLength, len(decoded))
		}
	})
}
