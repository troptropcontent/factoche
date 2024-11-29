package config

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestNewConfig(t *testing.T) {
	t.Run("When all required environment variables are set", func(t *testing.T) {
		t.Run("It should not panic", func(t *testing.T) {
			assert.NotPanics(t, func() {
				NewConfig()
			})
		})

		t.Run("It should return a config", func(t *testing.T) {
			config := NewConfig()
			assert.Equal(t, "test", config.App().Env())
			assert.Equal(t, "8080", config.App().Port())
			assert.Equal(t, "postgres://postgres:postgres@localhost:5432/factoche_test", config.DB().URL())
		})
	})

	t.Run("When some required environment variables are not se", func(t *testing.T) {
		t.Run("It should panic", func(t *testing.T) {
			os.Unsetenv("FACTOCHE_APP_ENV")
			defer os.Setenv("FACTOCHE_APP_ENV", "test")
			assert.Panics(t, func() {
				NewConfig()
			})
		})
	})
}
