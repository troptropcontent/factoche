package auth_usecase

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	auth_entity "github.com/troptropcontent/factoche/internal/domain/entity/auth"
	auth_repository "github.com/troptropcontent/factoche/internal/domain/repository/auth"
	"github.com/troptropcontent/factoche/pkg/jwt"
	"github.com/troptropcontent/factoche/pkg/passhash"
)

// MockUserRepository is a mock implementation of the UserRepository interface
type MockUserRepository struct {
	mock.Mock
}

func (m *MockUserRepository) GetByEmail(ctx context.Context, email string) (*auth_entity.User, error) {
	args := m.Called(ctx, email)
	return args.Get(0).(*auth_entity.User), args.Error(1)
}

func (m *MockUserRepository) Create(ctx context.Context, user *auth_entity.User) error {
	args := m.Called(ctx, user)
	return args.Error(0)
}

// MockJWT is a mock implementation of the JWT interface
type MockJWT struct {
	mock.Mock
}

func (m *MockJWT) GenerateToken(userID, email string, duration time.Duration) (string, error) {
	args := m.Called(userID, email, duration)
	return args.String(0), args.Error(1)
}

func (m *MockJWT) VerifyToken(token string) (*jwt.Claims, error) {
	args := m.Called(token)
	return args.Get(0).(*jwt.Claims), args.Error(1)
}

// MockPasshash is a mock implementation of the Passhash interface
type MockPasshash struct {
	mock.Mock
}

func (m *MockPasshash) HashPassword(password string) (string, error) {
	args := m.Called(password)
	return args.String(0), args.Error(1)
}

func (m *MockPasshash) VerifyPassword(passwordHash string, password string) bool {
	args := m.Called(passwordHash, password)
	return args.Bool(0)
}

func setupUseCase() (LoginUseCase, *MockUserRepository, *MockJWT, *MockJWT, *MockPasshash) {
	mockUserRepo := new(MockUserRepository)
	mockAccessTokenJWT := new(MockJWT)
	mockRefreshTokenJWT := new(MockJWT)
	mockPasshash := new(MockPasshash)

	return NewLoginUseCase(mockUserRepo, mockAccessTokenJWT, mockRefreshTokenJWT, mockPasshash), mockUserRepo, mockAccessTokenJWT, mockRefreshTokenJWT, mockPasshash
}

type testCase struct {
	name          string
	email         string
	password      string
	mockSetup     func(*MockUserRepository, *MockJWT, *MockJWT, *MockPasshash, *auth_entity.User)
	expectedError error
}

func setupTestUser() (*auth_entity.User, string) {
	email := "test@example.com"
	password := "password123"
	hashedPassword, _ := passhash.NewPasshash().HashPassword(password)
	return &auth_entity.User{ID: 1, Email: email, Password: hashedPassword}, password
}

func TestLoginUseCase_Execute(t *testing.T) {
	user, password := setupTestUser()
	ctx := context.Background()

	tests := []testCase{
		{
			name:     "Successful Login",
			email:    user.Email,
			password: password,
			mockSetup: func(ur *MockUserRepository, aJwt *MockJWT, rJwt *MockJWT, ph *MockPasshash, u *auth_entity.User) {
				ur.On("GetByEmail", ctx, u.Email).Return(u, nil)
				aJwt.On("GenerateToken", mock.Anything, u.Email, mock.Anything).Return("accessToken", nil)
				rJwt.On("GenerateToken", mock.Anything, u.Email, mock.Anything).Return("refreshToken", nil)
				ph.On("VerifyPassword", u.Password, password).Return(true)
			},
			expectedError: nil,
		},
		{
			name:     "User Not Found",
			email:    user.Email,
			password: password,
			mockSetup: func(ur *MockUserRepository, aJwt *MockJWT, rJwt *MockJWT, ph *MockPasshash, u *auth_entity.User) {
				ur.On("GetByEmail", ctx, u.Email).Return(&auth_entity.User{}, errors.New("user not found"))
			},
			expectedError: auth_repository.ErrUserNotFound,
		},
		{
			name:     "Incorrect Password",
			email:    user.Email,
			password: "wrongpassword",
			mockSetup: func(ur *MockUserRepository, aJwt *MockJWT, rJwt *MockJWT, ph *MockPasshash, u *auth_entity.User) {
				ur.On("GetByEmail", ctx, u.Email).Return(u, nil)
				ph.On("VerifyPassword", u.Password, "wrongpassword").Return(false)
			},
			expectedError: auth_repository.ErrUserNotFound,
		},
		{
			name:     "Token Generation Failure",
			email:    user.Email,
			password: password,
			mockSetup: func(ur *MockUserRepository, aJwt *MockJWT, rJwt *MockJWT, ph *MockPasshash, u *auth_entity.User) {
				ur.On("GetByEmail", ctx, u.Email).Return(u, nil)
				ph.On("VerifyPassword", u.Password, password).Return(true)
				aJwt.On("GenerateToken", mock.Anything, u.Email, mock.Anything).Return("", errors.New("token generation failed"))
				rJwt.On("GenerateToken", mock.Anything, u.Email, mock.Anything).Return("", errors.New("token generation failed"))
			},
			expectedError: auth_repository.ErrUserNotFound,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			useCase, mockUserRepo, mockAccessJwt, mockRefreshJwt, mockPasshash := setupUseCase()
			tc.mockSetup(mockUserRepo, mockAccessJwt, mockRefreshJwt, mockPasshash, user)

			accessToken, refreshToken, err := useCase.Execute(ctx, tc.email, tc.password)

			if tc.expectedError != nil {
				assert.Error(t, err)
				assert.Equal(t, tc.expectedError, err)
				assert.Empty(t, accessToken)
				assert.Empty(t, refreshToken)
			} else {
				assert.NoError(t, err)
				assert.Equal(t, "accessToken", accessToken)
				assert.Equal(t, "refreshToken", refreshToken)
			}

			mockUserRepo.AssertExpectations(t)
			mockAccessJwt.AssertExpectations(t)
			mockRefreshJwt.AssertExpectations(t)
			mockPasshash.AssertExpectations(t)
		})
	}
}
