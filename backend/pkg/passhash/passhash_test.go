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
			passhash := NewPasshash()
			hash, err := passhash.HashPassword(tt.password)

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
		passhash := NewPasshash()
		hash, err := passhash.HashPassword(password)
		assert.NoError(t, err)

		assert.True(t, passhash.VerifyPassword(hash, password))
	})

	t.Run("Invalid password verification", func(t *testing.T) {
		password := "MySecurePass123!"
		wrongPassword := "WrongPass123!"
		passhash := NewPasshash()
		hash, err := passhash.HashPassword(password)
		assert.NoError(t, err)

		assert.False(t, passhash.VerifyPassword(hash, wrongPassword))
	})
}

func TestHashUniqueness(t *testing.T) {
	t.Run("Same password produces different hashes", func(t *testing.T) {
		password := "MySecurePass123!"
		passhash := NewPasshash()
		hash1, err := passhash.HashPassword(password)
		assert.NoError(t, err)

		hash2, err := passhash.HashPassword(password)
		assert.NoError(t, err)

		assert.NotEqual(t, hash1, hash2)

		assert.True(t, passhash.VerifyPassword(hash1, password))
		assert.True(t, passhash.VerifyPassword(hash2, password))
	})
}

func TestPerformance(t *testing.T) {
	t.Run("Hash performance", func(t *testing.T) {
		password := "MySecurePass123!"
		passhash := NewPasshash()

		hash, err := passhash.HashPassword(password)
		assert.NoError(t, err)
		assert.NotEmpty(t, hash)
	})
}

func BenchmarkHashPassword(b *testing.B) {
	password := "MySecurePass123!"
	passhash := NewPasshash()
	for i := 0; i < b.N; i++ {
		_, err := passhash.HashPassword(password)
		if err != nil {
			b.Fatal(err)
		}
	}
}

func BenchmarkVerifyPassword(b *testing.B) {
	password := "MySecurePass123!"
	passhash := NewPasshash()
	hash, err := passhash.HashPassword(password)
	if err != nil {
		b.Fatal(err)
	}

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		passhash.VerifyPassword(hash, password)
	}
}
