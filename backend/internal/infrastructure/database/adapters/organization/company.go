package organization_adapters

import (
	"context"
	"fmt"

	organization_entity "github.com/troptropcontent/factoche/internal/domain/entity/organization"
	organization_repository "github.com/troptropcontent/factoche/internal/domain/repository/organization"
	organization_model "github.com/troptropcontent/factoche/internal/infrastructure/database/postgres/models/organization"
	"gorm.io/gorm"
)

type companyAdapter struct {
	db *gorm.DB
}

func NewCompanyRepository(db *gorm.DB) organization_repository.CompanyRepository {
	return &companyAdapter{db: db}
}

func (r *companyAdapter) Create(ctx context.Context, company *organization_entity.Company) error {
	model := &organization_model.Company{}
	model.FromEntity(company)

	result := r.db.WithContext(ctx).Create(model)
	if result.Error != nil {
		fmt.Println("ERROR IN r.db.WithContext(ctx).Create(model): ", result.Error)
		return result.Error
	}

	*company = *model.ToEntity()

	return nil
}
