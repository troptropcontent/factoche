package auth_models

import (
	auth_entity "github.com/troptropcontent/factoche/internal/domain/entity/auth"
	"gorm.io/gorm"
)

type User struct {
	gorm.Model
	Email    string
	Password string
}

// ToEntity converts the GORM model to a domain entity
func (u *User) ToEntity() *auth_entity.User {
	return &auth_entity.User{
		ID:        u.ID,
		Email:     u.Email,
		Password:  u.Password,
		CreatedAt: u.CreatedAt,
		UpdatedAt: u.UpdatedAt,
		DeletedAt: u.DeletedAt.Time,
	}
}

// FromEntity converts a domain entity to a GORM model
func (u *User) FromEntity(user *auth_entity.User) {
	u.ID = user.ID
	u.Email = user.Email
	u.Password = user.Password
}
