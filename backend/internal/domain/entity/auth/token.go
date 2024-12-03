package auth_entity

import "time"

// Token represents an authentication token pair
type Token struct {
	AccessToken  string    `json:"access_token"`
	RefreshToken string    `json:"refresh_token"`
	ExpiresAt    int64     `json:"expires_at"`
	TokenType    string    `json:"token_type"` // Usually "Bearer"
	IssuedAt     time.Time `json:"issued_at"`
}

type TokenClaims struct {
	UserID    string    `json:"user_id"`
	Email     string    `json:"email"`
	TokenID   string    `json:"token_id"`   // Unique identifier for token revocation
	TokenType string    `json:"token_type"` // "access" or "refresh"
	IssuedAt  time.Time `json:"iat"`
	ExpiresAt time.Time `json:"exp"`
}
