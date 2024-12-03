package jwt

import (
	"strings"
	"testing"
	"time"
)

func TestJWT_GenerateToken(t *testing.T) {
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
}

func TestJWT_VerifyToken(t *testing.T) {
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
	}{
		{
			name: "valid token",
			setup: func() string {
				token, _ := jwt.GenerateToken(userID, email, duration)
				return token
			},
			jwt:     jwt,
			wantErr: false,
		},
		{
			name: "invalid token format",
			setup: func() string {
				return "invalid.token.string"
			},
			jwt:     jwt,
			wantErr: true,
		},
		{
			name: "expired token",
			setup: func() string {
				token, _ := jwt.GenerateToken(userID, email, -time.Hour)
				return token
			},
			jwt:     jwt,
			wantErr: true,
		},
		{
			name: "malformed token",
			setup: func() string {
				return "header.payload" // missing signature part
			},
			jwt:     jwt,
			wantErr: true,
		},
		{
			name: "empty token",
			setup: func() string {
				return ""
			},
			jwt:     jwt,
			wantErr: true,
		},
		{
			name: "wrong secret key",
			setup: func() string {
				token, _ := jwt.GenerateToken(userID, email, duration)
				return token
			},
			jwt:     wrongJWT,
			wantErr: true,
		},
		{
			name: "token with special characters",
			setup: func() string {
				token, _ := jwt.GenerateToken("123!@#$%^&*()", "test+special@example.com", duration)
				return token
			},
			jwt:     jwt,
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			token := tt.setup()
			claims, err := tt.jwt.VerifyToken(token)

			if (err != nil) != tt.wantErr {
				t.Errorf("VerifyToken() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			if !tt.wantErr && claims != nil {
				// Verify claims content
				if claims.UserID == "" {
					t.Error("VerifyToken() UserID is empty")
				}
				if claims.Email == "" {
					t.Error("VerifyToken() Email is empty")
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

func TestJWT_DifferentSecretKeys(t *testing.T) {
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
