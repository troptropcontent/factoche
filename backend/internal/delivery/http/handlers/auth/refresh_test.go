package auth_handler

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/labstack/echo/v4"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// MockRefreshUseCase is a mock implementation of the RefreshUseCase
type MockRefreshUseCase struct {
	mock.Mock
}

func (m *MockRefreshUseCase) Execute(ctx context.Context, refreshToken string) (string, error) {
	args := m.Called(ctx, refreshToken)
	return args.String(0), args.Error(1)
}

func TestRefreshHandler_Handle(t *testing.T) {
	tests := []struct {
		name                    string
		requestBody             string
		setupMockRefreshUseCase func(m *MockRefreshUseCase)
		expectedStatus          int
		expectedErrorMessage    string
		expectedResponse        string
	}{
		{
			name:        "Success",
			requestBody: `{"refresh_token": "valid_refresh_token"}`,
			setupMockRefreshUseCase: func(m *MockRefreshUseCase) {
				m.On("Execute", mock.Anything, "valid_refresh_token").Return("new_access_token", nil)
			},
			expectedStatus:       http.StatusOK,
			expectedResponse:     `{"access_token":"new_access_token"}`,
			expectedErrorMessage: "",
		},
		{
			name:                 "Invalid JSON",
			requestBody:          `{invalid json}`,
			expectedStatus:       http.StatusBadRequest,
			expectedErrorMessage: "invalid request format",
		},
		{
			name:        "Invalid Refresh Token",
			requestBody: `{"refresh_token": "invalid_token"}`,
			setupMockRefreshUseCase: func(m *MockRefreshUseCase) {
				m.On("Execute", mock.Anything, "invalid_token").Return("", errors.New("invalid token"))
			},
			expectedStatus:       http.StatusUnauthorized,
			expectedErrorMessage: "invalid credentials",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Setup
			e := echo.New()
			req := httptest.NewRequest(http.MethodPost, "/refresh", strings.NewReader(tt.requestBody))
			req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)
			rec := httptest.NewRecorder()
			c := e.NewContext(req, rec)

			mockUseCase := new(MockRefreshUseCase)
			if tt.setupMockRefreshUseCase != nil {
				tt.setupMockRefreshUseCase(mockUseCase)
			}

			handler := NewRefreshHandler(mockUseCase)

			// Test
			err := handler.Handle(c)

			// Assertions
			if tt.expectedErrorMessage != "" {
				assert.Error(t, err)
				httpError, ok := err.(*echo.HTTPError)
				assert.True(t, ok)
				assert.Equal(t, tt.expectedStatus, httpError.Code)
				assert.Equal(t, tt.expectedErrorMessage, httpError.Message)
			} else {
				assert.NoError(t, err)
				assert.Equal(t, tt.expectedStatus, rec.Code)
				assert.JSONEq(t, tt.expectedResponse, rec.Body.String())
			}

			if tt.setupMockRefreshUseCase != nil {
				mockUseCase.AssertExpectations(t)
			}
		})
	}
}
