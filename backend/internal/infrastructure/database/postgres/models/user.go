package models

import (
	"github.com/troptropcontent/factoche/internal/domain/entity"
	"gorm.io/gorm"
)

type User struct {
	gorm.Model
	Email     string `gorm:"uniqueIndex;not null"`
	Password  string `gorm:"not null"`
	FirstName string
	LastName  string
}

// ToEntity converts the GORM model to a domain entity
func (u *User) ToEntity() *entity.User {
	return &entity.User{
		ID:        u.ID,
		Email:     u.Email,
		Password:  u.Password,
		CreatedAt: u.CreatedAt,
		UpdatedAt: u.UpdatedAt,
		DeletedAt: u.DeletedAt.Time,
	}
}

// FromEntity converts a domain entity to a GORM model
func (u *User) FromEntity(user *entity.User) {
	u.ID = user.ID
	u.Email = user.Email
	u.Password = user.Password
}
