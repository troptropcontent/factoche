package organization_entity

import (
	"testing"
	"time"
)

func TestMember_Validate(t *testing.T) {
	tests := []struct {
		name              string
		member            Member
		expectedErrorMess string
	}{
		{
			name: "valid member",
			member: Member{
				ID:        1,
				UserID:    1,
				CompanyID: 1,
				Role:      "admin",
				CreatedAt: time.Now(),
				UpdatedAt: time.Now(),
				DeletedAt: time.Now(),
			},
			expectedErrorMess: "",
		},
		{
			name: "invalid member - missing ID",
			member: Member{
				UserID:    1,
				CompanyID: 1,
				Role:      "admin",
				CreatedAt: time.Now(),
				UpdatedAt: time.Now(),
				DeletedAt: time.Now(),
			},
			expectedErrorMess: "Key: 'Member.ID' Error:Field validation for 'ID' failed on the 'required' tag",
		},
		{
			name: "invalid member - missing Role",
			member: Member{
				ID:        1,
				UserID:    1,
				CompanyID: 1,
				CreatedAt: time.Now(),
				UpdatedAt: time.Now(),
				DeletedAt: time.Now(),
			},
			expectedErrorMess: "Key: 'Member.Role' Error:Field validation for 'Role' failed on the 'required' tag",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.member.Validate()
			if err != nil && err.Error() != tt.expectedErrorMess {
				t.Errorf("Member.Validate() error = %v, wantErr %v", err, tt.expectedErrorMess)
			}
		})
	}
}
