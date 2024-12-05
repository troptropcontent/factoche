package passhash

import (
	"fmt"

	"golang.org/x/crypto/bcrypt"
)

type Passhash interface {
	HashPassword(password string) (string, error)
	VerifyPassword(passwordHash string, password string) bool
}

type passhash struct{}

// Returns a new Passhash instance
func NewPasshash() Passhash {
	return &passhash{}
}

// Password hashing methods
func (p *passhash) HashPassword(password string) (string, error) {
	if len(password) == 0 {
		return "", fmt.Errorf("password is empty")
	}
	hashedBytes, err := bcrypt.GenerateFromPassword(
		[]byte(password),
		bcrypt.DefaultCost,
	)
	if err != nil {
		return "", fmt.Errorf("failed to hash password: %w", err)
	}
	return string(hashedBytes), nil
}

func (p *passhash) VerifyPassword(passwordHash string, password string) bool {
	err := bcrypt.CompareHashAndPassword(
		[]byte(passwordHash),
		[]byte(password),
	)
	return err == nil
}
