package auth_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/labstack/echo/v4"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/troptropcontent/factoche/internal/config"
	auth_handler "github.com/troptropcontent/factoche/internal/delivery/http/auth"
	"github.com/troptropcontent/factoche/internal/infrastructure/database/postgres"
	auth_repositories "github.com/troptropcontent/factoche/internal/infrastructure/database/repositories/auth"
	auth_usecase "github.com/troptropcontent/factoche/internal/usecase/auth"
	"github.com/troptropcontent/factoche/pkg/jwt"
	"gorm.io/gorm"
)

func TestLoginEndpoint(t *testing.T) {
	// Initialize Echo
	e := echo.New()

	// Setup
	config := config.NewConfig()
	db, _ := postgres.NewConnection(config.DB())

	// Define test cases
	tests := []struct {
		name             string
		requestBody      string
		expectedStatus   int
		validateResponse func(t *testing.T, body string)
		beforeTest       func(trans *gorm.DB)
	}{
		{
			name:           "Successful login",
			requestBody:    `{"email":"validUser@example.com", "password":"validPassword"}`,
			expectedStatus: http.StatusOK,
			validateResponse: func(t *testing.T, body string) {
				assert.Contains(t, body, "accessToken")
				assert.Contains(t, body, "refreshToken")
			},
			beforeTest: func(trans *gorm.DB) {
				uc := auth_usecase.NewUserUseCase(auth_repositories.NewUserRepository(trans))
				_, err := uc.CreateUser(context.Background(), "validUser@example.com", "validPassword")
				require.NoError(t, err)
			},
		},
		{
			name:           "Invalid credentials",
			requestBody:    `{"username":"invalidUser", "password":"invalidPassword"}`,
			expectedStatus: http.StatusUnauthorized,
			validateResponse: func(t *testing.T, body string) {
				assert.Contains(t, body, "invalid credentials")
			},
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			trans := db.Begin()
			defer trans.Rollback()

			if tc.beforeTest != nil {
				tc.beforeTest(trans)
			}

			userRepo := auth_repositories.NewUserRepository(trans)
			jwtService := jwt.NewJWT(config.JWT().SecretKey())
			loginUseCase := auth_usecase.NewLoginUseCase(userRepo, *jwtService)
			loginHandler := auth_handler.NewLoginHandler(loginUseCase)

			auth := e.Group("auth")
			auth.POST("/login", loginHandler.Handle) // Assuming loginHandler is accessible

			// Create a new HTTP request
			req := httptest.NewRequest(http.MethodPost, "/auth/login", strings.NewReader(tc.requestBody))
			req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)

			// Create a new HTTP response recorder
			rec := httptest.NewRecorder()

			// Serve the HTTP request
			e.ServeHTTP(rec, req)

			// Assert the response
			assert.Equal(t, tc.expectedStatus, rec.Code)
			tc.validateResponse(t, rec.Body.String())
		})
	}
}
