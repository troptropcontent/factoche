package organization_model

import (
	organization_entity "github.com/troptropcontent/factoche/internal/domain/entity/organization"
	"gorm.io/gorm"
)

type Member struct {
	gorm.Model
	UserID    uint
	CompanyID uint
	Role      string
}

func (m *Member) ToEntity() *organization_entity.Member {
	return &organization_entity.Member{
		ID:        m.ID,
		UserID:    m.UserID,
		CompanyID: m.CompanyID,
		Role:      m.Role,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		DeletedAt: m.DeletedAt.Time,
	}
}

func (m *Member) FromEntity(member *organization_entity.Member) {
	m.ID = member.ID
	m.UserID = member.UserID
	m.CompanyID = member.CompanyID
	m.Role = member.Role
	m.CreatedAt = member.CreatedAt
	m.UpdatedAt = member.UpdatedAt
	m.DeletedAt = gorm.DeletedAt{Time: member.DeletedAt}
}
