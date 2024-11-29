package config

type AppConfig interface {
	Env() string
	Port() string
}

type DBConfig interface {
	URL() string
}

type Config interface {
	App() AppConfig
	DB() DBConfig
}
