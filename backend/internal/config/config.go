package config

import (
	"github.com/troptropcontent/factoche/pkg/env"
)

// AppConfig is the configuration for the application
type appConfig struct {
	env  string
	port string
}

func (c *appConfig) Env() string  { return c.env }
func (c *appConfig) Port() string { return c.port }

// DBConfig is the configuration for the database
type dbConfig struct {
	host     string
	user     string
	password string
	name     string
	port     string
}

func (c *dbConfig) Host() string     { return c.host }
func (c *dbConfig) Port() string     { return c.port }
func (c *dbConfig) Name() string     { return c.name }
func (c *dbConfig) User() string     { return c.user }
func (c *dbConfig) Password() string { return c.password }

// JWTConfig is the configuration for the JWT
type jwtConfig struct {
	accessTokenSecretKey  string
	refreshTokenSecretKey string
}

func (c *jwtConfig) AccessTokenSecretKey() string  { return c.accessTokenSecretKey }
func (c *jwtConfig) RefreshTokenSecretKey() string { return c.refreshTokenSecretKey }

// Config wraps all sub-configurations (app and db)
type config struct {
	app AppConfig
	db  DBConfig
	jwt JWTConfig
}

func (c *config) App() AppConfig { return c.app }
func (c *config) DB() DBConfig   { return c.db }
func (c *config) JWT() JWTConfig { return c.jwt }

// NewConfig creates a new configuration by loading environment variables
// It will panic if any of the environment variables are not set
func NewConfig() Config {
	env := env.NewEnv("FACTOCHE")
	return &config{
		app: &appConfig{
			env:  env.MustGet("APP_ENV"),
			port: env.MustGet("APP_PORT"),
		},
		db: &dbConfig{
			host:     env.MustGet("DB_HOST"),
			port:     env.MustGet("DB_PORT"),
			name:     env.MustGet("DB_NAME"),
			user:     env.MustGet("DB_USER"),
			password: env.MustGet("DB_PASSWORD"),
		},
		jwt: &jwtConfig{
			accessTokenSecretKey:  env.MustGet("JWT_ACCESS_TOKEN_SECRET_KEY"),
			refreshTokenSecretKey: env.MustGet("JWT_REFRESH_TOKEN_SECRET_KEY"),
		},
	}
}
