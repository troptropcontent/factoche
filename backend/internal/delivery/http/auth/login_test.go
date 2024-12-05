package auth_handler

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/labstack/echo/v4"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	auth_repository "github.com/troptropcontent/factoche/internal/domain/repository/auth"
)

// Mock LoginUseCase
type mockLoginUseCase struct {
	mock.Mock
}

func (m *mockLoginUseCase) Execute(ctx context.Context, email, password string) (string, string, error) {
	args := m.Called(ctx, email, password)
	return args.String(0), args.String(1), args.Error(2)
}

func Test_LoginHandler_Handle(t *testing.T) {
	tests := []struct {
		name           string
		requestBody    LoginRequest
		setupMock      func(*mockLoginUseCase)
		expectedStatus int
		expectedBody   interface{}
	}{
		{
			name: "successful login",
			requestBody: LoginRequest{
				Email:    "test@example.com",
				Password: "password123",
			},
			setupMock: func(m *mockLoginUseCase) {
				m.On("Execute", mock.Anything, "test@example.com", "password123").
					Return("access_token", "refresh_token", nil)
			},
			expectedStatus: http.StatusOK,
			expectedBody: LoginResponse{
				AccessToken:  "access_token",
				RefreshToken: "refresh_token",
			},
		},
		{
			name: "invalid credentials",
			requestBody: LoginRequest{
				Email:    "test@example.com",
				Password: "wrongpassword",
			},
			setupMock: func(m *mockLoginUseCase) {
				m.On("Execute", mock.Anything, "test@example.com", "wrongpassword").
					Return("", "", auth_repository.ErrUserNotFound)
			},
			expectedStatus: http.StatusUnauthorized,
			expectedBody: map[string]string{
				"message": "invalid credentials",
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Setup
			e := echo.New()
			mockUC := new(mockLoginUseCase)
			tt.setupMock(mockUC)
			handler := NewLoginHandler(mockUC)

			// Create request
			body, _ := json.Marshal(tt.requestBody)
			req := httptest.NewRequest(http.MethodPost, "/login", bytes.NewBuffer(body))
			req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
			rec := httptest.NewRecorder()
			c := e.NewContext(req, rec)

			// Execute request
			err := handler.Handle(c)
			if err != nil {
				he, ok := err.(*echo.HTTPError)
				if ok {
					assert.Equal(t, tt.expectedStatus, he.Code)
					assert.Equal(t, tt.expectedBody.(map[string]string)["message"], he.Message)
					return
				}
				t.Errorf("unexpected error type: %v", err)
				return
			}

			// Assert response
			assert.Equal(t, tt.expectedStatus, rec.Code)

			var response LoginResponse
			json.Unmarshal(rec.Body.Bytes(), &response)
			assert.Equal(t, tt.expectedBody, response)

			// Verify mock expectations
			mockUC.AssertExpectations(t)
		})
	}
}
