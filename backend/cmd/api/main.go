package main

import (
	"fmt"
	"log"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/troptropcontent/factoche/internal/config"
	auth_handler "github.com/troptropcontent/factoche/internal/delivery/http/auth"
	"github.com/troptropcontent/factoche/internal/infrastructure/database/postgres"
	auth_repositories "github.com/troptropcontent/factoche/internal/infrastructure/database/repositories/auth"
	auth_usecase "github.com/troptropcontent/factoche/internal/usecase/auth"
	"github.com/troptropcontent/factoche/pkg/jwt"
	"github.com/troptropcontent/factoche/pkg/passhash"
)

func main() {
	config := config.NewConfig()

	db, err := postgres.NewConnection(config.DB())
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	// Initialize repositories
	userRepo := auth_repositories.NewUserRepository(db)

	// Initialize services
	jwtService := jwt.NewJWT(config.JWT().SecretKey())

	// Initialize hasher
	hasher := passhash.NewPasshash()

	// Initialize use_cases
	loginUseCase := auth_usecase.NewLoginUseCase(userRepo, jwtService, hasher)

	// Initialize handlers
	loginHandler := auth_handler.NewLoginHandler(loginUseCase)

	// Setup server
	e := echo.New()
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Use(middleware.CORS())

	// Routes
	auth := e.Group("auth")
	auth.POST("/login", loginHandler.Handle)

	// Start server
	if err := e.Start(fmt.Sprintf(":%s", config.App().Port())); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
