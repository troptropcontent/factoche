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

type Config interface {
	App() AppConfig
	DB() DBConfig
}
