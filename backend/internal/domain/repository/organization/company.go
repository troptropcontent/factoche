package organization_repository

import (
	"context"

	organization_entity "github.com/troptropcontent/factoche/internal/domain/entity/organization"
)

type CompanyRepository interface {
	Create(ctx context.Context, client *organization_entity.Company) error
}
