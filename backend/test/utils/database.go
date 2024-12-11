package testutils

import (
	"testing"

	"github.com/troptropcontent/factoche/internal/config"
	"github.com/troptropcontent/factoche/internal/infrastructure/database/postgres"
	"gorm.io/gorm"
)

// WithTransaction executes the given function within a database transaction
// and automatically rolls back the transaction after the test.
func WithinTransaction(t *testing.T, fn func(db *gorm.DB)) {
	config := config.NewConfig()
	connection, err := postgres.NewConnection(config.DB())
	if err != nil {
		t.Fatalf("failed to connect database: %v", err)
	}

	transaction := connection.Begin()
	defer transaction.Rollback()

	fn(transaction)
}
