package env

import (
	"os"
)

type Env interface {
	MustGet(key string) string
	Get(key string) string
}

type env struct {
	prefix string
}

func NewEnv(prefix string) Env {
	return &env{prefix: prefix}
}

func (e *env) envKey(key string) string {
	return e.prefix + "_" + key
}

func (e *env) MustGet(key string) string {
	value := e.Get(key)
	if value == "" {
		panic("environment variable " + e.envKey(key) + " is not set")
	}

	return value
}

func (e *env) Get(key string) string {
	return os.Getenv(e.envKey(key))
}
