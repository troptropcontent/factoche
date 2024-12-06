package config

type AppConfig interface {
	Env() string
	Port() string
}

type DBConfig interface {
	Host() string
	Port() string
	Name() string
	User() string
	Password() string
}

type JWTConfig interface {
	AccessTokenSecretKey() string
	RefreshTokenSecretKey() string
}

type Config interface {
	App() AppConfig
	DB() DBConfig
	JWT() JWTConfig
}
