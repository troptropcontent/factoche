package auth_usecase

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"github.com/troptropcontent/factoche/pkg/jwt"
)

// Mock JWT service
type MockJWTService struct {
	mock.Mock
}

func (m *MockJWTService) GenerateToken(userID string, email string, duration time.Duration) (string, error) {
	args := m.Called(userID, email, duration)
	return args.String(0), args.Error(1)
}

func (m *MockJWTService) VerifyToken(token string) (*jwt.Claims, error) {
	args := m.Called(token)
	if claims, ok := args.Get(0).(*jwt.Claims); ok {
		return claims, args.Error(1)
	}
	return nil, args.Error(1)
}

func TestRefreshUseCase_Execute(t *testing.T) {
	tests := []struct {
		name          string
		refreshToken  string
		setupMocks    func(*MockJWTService, *MockJWTService)
		expectedToken string
		expectedError error
	}{
		{
			name:         "Success - Valid refresh token",
			refreshToken: "valid.refresh.token",
			setupMocks: func(mockAccessJWT, mockRefreshJWT *MockJWTService) {
				mockRefreshJWT.On("VerifyToken", "valid.refresh.token").Return(&jwt.Claims{
					UserID: "user123",
					Email:  "user@example.com",
				}, nil)

				mockAccessJWT.On("GenerateToken", "user123", "user@example.com", ACCESS_TOKEN_DURATION).
					Return("new.access.token", nil)
			},
			expectedToken: "new.access.token",
			expectedError: nil,
		},
		{
			name:         "Error - Invalid refresh token",
			refreshToken: "invalid.refresh.token",
			setupMocks: func(mockAccessJWT, mockRefreshJWT *MockJWTService) {
				mockRefreshJWT.On("VerifyToken", "invalid.refresh.token").
					Return(nil, errors.New("token invalid"))
			},
			expectedToken: "",
			expectedError: errors.New("invalid token"),
		},
		{
			name:         "Error - Failed to generate access token",
			refreshToken: "valid.refresh.token",
			setupMocks: func(mockAccessJWT, mockRefreshJWT *MockJWTService) {
				mockRefreshJWT.On("VerifyToken", "valid.refresh.token").Return(&jwt.Claims{
					UserID: "user123",
					Email:  "user@example.com",
				}, nil)

				mockAccessJWT.On("GenerateToken", "user123", "user@example.com", ACCESS_TOKEN_DURATION).
					Return("", errors.New("generation failed"))
			},
			expectedToken: "",
			expectedError: errors.New("error while creating token"),
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Setup
			mockAccessJWT := new(MockJWTService)
			mockRefreshJWT := new(MockJWTService)
			tt.setupMocks(mockAccessJWT, mockRefreshJWT)

			useCase := NewRefreshUseCase(mockAccessJWT, mockRefreshJWT)

			// Execute
			token, err := useCase.Execute(context.Background(), tt.refreshToken)

			// Assert
			if tt.expectedError != nil {
				assert.Error(t, err)
				assert.Equal(t, tt.expectedError.Error(), err.Error())
			} else {
				assert.NoError(t, err)
			}
			assert.Equal(t, tt.expectedToken, token)

			// Verify all mocked calls were made
			mockAccessJWT.AssertExpectations(t)
			mockRefreshJWT.AssertExpectations(t)
		})
	}
}
