package auth_test

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/labstack/echo/v4"
	"github.com/stretchr/testify/assert"
	"github.com/troptropcontent/factoche/internal/config"
	auth_handler "github.com/troptropcontent/factoche/internal/delivery/http/handlers/auth"
	auth_usecase "github.com/troptropcontent/factoche/internal/usecase/auth"
	"github.com/troptropcontent/factoche/pkg/jwt"
)

func TestRefreshEndpoint(t *testing.T) {
	// Initialize Echo
	e := echo.New()

	// Setup
	config := config.NewConfig()
	accessTokenJwtService := jwt.NewJWT(config.JWT().AccessTokenSecretKey())
	refreshTokenJwtService := jwt.NewJWT(config.JWT().RefreshTokenSecretKey())
	validRefreshToken, _ := refreshTokenJwtService.GenerateToken("1", "validUser@example.com", auth_usecase.REFRESH_TOKEN_DURATION)

	// Define test cases
	tests := []struct {
		name             string
		requestBody      string
		expectedStatus   int
		validateResponse func(t *testing.T, body string)
	}{
		{
			name:           "Successful refresh",
			requestBody:    `{"refresh_token":"` + validRefreshToken + `"}`,
			expectedStatus: http.StatusOK,
			validateResponse: func(t *testing.T, body string) {
				assert.Contains(t, body, "access_token")
			},
		},
		{
			name:           "Empty refresh token",
			requestBody:    `{"refresh_token":""}`,
			expectedStatus: http.StatusBadRequest,
			validateResponse: func(t *testing.T, body string) {
				assert.Contains(t, body, "invalid request format")
			},
		},
		{
			name:           "Empty body",
			requestBody:    ``,
			expectedStatus: http.StatusBadRequest,
			validateResponse: func(t *testing.T, body string) {
				assert.Contains(t, body, "invalid request format")
			},
		},
		{
			name:           "Invalid JSON",
			requestBody:    `invalid_json`,
			expectedStatus: http.StatusBadRequest,
			validateResponse: func(t *testing.T, body string) {
				assert.Contains(t, body, "invalid request format")
			},
		},
		{
			name:           "Invalid refresh token",
			requestBody:    `{"refresh_token":"invalid_refresh_token"}`,
			expectedStatus: http.StatusUnauthorized,
			validateResponse: func(t *testing.T, body string) {
				assert.Contains(t, body, "invalid credentials")
			},
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			// Setup
			refreshUseCase := auth_usecase.NewRefreshUseCase(accessTokenJwtService, refreshTokenJwtService)
			refreshHandler := auth_handler.NewRefreshHandler(refreshUseCase)

			auth := e.Group("auth")
			auth.POST("/refresh", refreshHandler.Handle)

			// Create a new HTTP request
			req := httptest.NewRequest(http.MethodPost, "/auth/refresh", strings.NewReader(tc.requestBody))
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
