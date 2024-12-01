package postgres

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

type mockDBConfig struct {
	host     string
	user     string
	password string
	name     string
	port     string
}

func (m mockDBConfig) Host() string     { return m.host }
func (m mockDBConfig) User() string     { return m.user }
func (m mockDBConfig) Password() string { return m.password }
func (m mockDBConfig) Name() string     { return m.name }
func (m mockDBConfig) Port() string     { return m.port }

func TestNewConnection(t *testing.T) {
	tests := []struct {
		name     string
		config   mockDBConfig
		wantErr  bool
		errorMsg string
	}{
		{
			name: "successful connection",
			config: mockDBConfig{
				host:     "db",
				user:     "postgres",
				password: "postgres",
				name:     "factoche_test",
				port:     "5432",
			},
			wantErr:  false,
			errorMsg: "",
		},
		{
			name: "failed connection - wrong host",
			config: mockDBConfig{
				host:     "wrong_host",
				user:     "postgres",
				password: "postgres",
				name:     "factoche_test",
				port:     "5432",
			},
			wantErr:  true,
			errorMsg: "no such host",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			db, err := NewConnection(tt.config)

			if tt.wantErr {
				assert.Error(t, err)
				assert.Nil(t, db)
				assert.Contains(t, err.Error(), tt.errorMsg)
			} else {
				assert.NoError(t, err)
				assert.NotNil(t, db)

				// Verify connection works
				sqlDB, err := db.DB()
				assert.NoError(t, err)
				assert.NoError(t, sqlDB.Ping())
			}
		})
	}
}
