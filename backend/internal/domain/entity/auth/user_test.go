package auth_entity

import (
	"testing"
)

type testCase struct {
	name    string
	user    User
	wantErr string
}

func TestUser_Validate(t *testing.T) {
	tests := []testCase{
		{
			name: "valid user",
			user: User{
				Email:    "test@example.com",
				Password: "password123",
			},
			wantErr: "",
		},
		{
			name: "invalid email format",
			user: User{
				Email:    "invalid-email",
				Password: "password123",
			},
			wantErr: "Key: 'User.Email' Error:Field validation for 'Email' failed on the 'email' tag",
		},
		{
			name: "empty email",
			user: User{
				Email:    "",
				Password: "password123",
			},
			wantErr: "Key: 'User.Email' Error:Field validation for 'Email' failed on the 'required' tag",
		},
		{
			name: "empty password",
			user: User{
				Email:    "test@example.com",
				Password: "",
			},
			wantErr: "Key: 'User.Password' Error:Field validation for 'Password' failed on the 'required' tag",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.user.Validate()
			if err != nil && err.Error() != tt.wantErr {
				t.Errorf("User.Validate() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}
