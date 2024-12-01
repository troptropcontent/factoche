package migrator

import (
	"fmt"

	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"github.com/troptropcontent/factoche/internal/config"
	"gorm.io/gorm"
)

type Migrator interface {
	Up() error
	Down() error
}

type migrator struct {
	migrate *migrate.Migrate
}

func New(db *gorm.DB, config config.DBConfig) (Migrator, error) {
	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("failed to get underlying sql.DB: %w", err)
	}

	// Initialize postgres driver
	driver, err := postgres.WithInstance(sqlDB, &postgres.Config{})
	if err != nil {
		return nil, fmt.Errorf("failed to create postgres driver: %w", err)
	}

	// Initialize migrator
	m, err := migrate.NewWithDatabaseInstance(
		"file://internal/infrastructure/database/postgres/migrations",
		config.Name(),
		driver,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to create migrator: %w", err)
	}

	return &migrator{migrate: m}, nil
}

func (m *migrator) Up() error {
	if err := m.migrate.Up(); err != nil && err != migrate.ErrNoChange {
		return fmt.Errorf("failed to run migrations: %w", err)
	}
	return nil
}

func (m *migrator) Down() error {
	if err := m.migrate.Down(); err != nil && err != migrate.ErrNoChange {
		return fmt.Errorf("failed to rollback migrations: %w", err)
	}
	return nil
}
