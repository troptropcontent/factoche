package passhash

import (
	"fmt"

	"golang.org/x/crypto/bcrypt"
)

// Password hashing methods
func HashPassword(password string) (string, error) {
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

func VerifyPassword(passwordHash string, password string) bool {
	err := bcrypt.CompareHashAndPassword(
		[]byte(passwordHash),
		[]byte(password),
	)
	return err == nil
}
