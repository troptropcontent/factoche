package passhash

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestHashPassword(t *testing.T) {
	tests := []struct {
		name        string
		password    string
		shouldError bool
	}{
		{
			name:        "Valid password",
			password:    "MySecurePass123!",
			shouldError: false,
		},
		{
			name:        "Empty password",
			password:    "",
			shouldError: true,
		},
		{
			name:        "Long password",
			password:    strings.Repeat("a", 72), // bcrypt's max length
			shouldError: false,
		},
		{
			name:        "Too long password",
			password:    strings.Repeat("a", 73), // bcrypt's max length + 1
			shouldError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			hash, err := HashPassword(tt.password)

			if tt.shouldError {
				assert.Error(t, err)
				assert.Empty(t, hash)
			} else {
				assert.NoError(t, err)
				assert.NotEmpty(t, hash)

				assert.True(t, strings.HasPrefix(hash, "$2a$"))
			}
		})
	}
}

func TestVerifyPassword(t *testing.T) {
	t.Run("Valid password verification", func(t *testing.T) {
		password := "MySecurePass123!"
		hash, err := HashPassword(password)
		assert.NoError(t, err)

		assert.True(t, VerifyPassword(hash, password))
	})

	t.Run("Invalid password verification", func(t *testing.T) {
		password := "MySecurePass123!"
		wrongPassword := "WrongPass123!"
		hash, err := HashPassword(password)
		assert.NoError(t, err)

		assert.False(t, VerifyPassword(hash, wrongPassword))
	})
}

func TestHashUniqueness(t *testing.T) {
	t.Run("Same password produces different hashes", func(t *testing.T) {
		password := "MySecurePass123!"

		hash1, err := HashPassword(password)
		assert.NoError(t, err)

		hash2, err := HashPassword(password)
		assert.NoError(t, err)

		assert.NotEqual(t, hash1, hash2)

		assert.True(t, VerifyPassword(hash1, password))
		assert.True(t, VerifyPassword(hash2, password))
	})
}

func TestPerformance(t *testing.T) {
	t.Run("Hash performance", func(t *testing.T) {
		password := "MySecurePass123!"

		hash, err := HashPassword(password)
		assert.NoError(t, err)
		assert.NotEmpty(t, hash)
	})
}

func BenchmarkHashPassword(b *testing.B) {
	password := "MySecurePass123!"

	for i := 0; i < b.N; i++ {
		_, err := HashPassword(password)
		if err != nil {
			b.Fatal(err)
		}
	}
}

func BenchmarkVerifyPassword(b *testing.B) {
	password := "MySecurePass123!"
	hash, err := HashPassword(password)
	if err != nil {
		b.Fatal(err)
	}

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		VerifyPassword(hash, password)
	}
}
