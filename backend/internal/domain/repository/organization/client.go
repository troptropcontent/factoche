package organization_repository

import (
	"context"

	organization_entity "github.com/troptropcontent/factoche/internal/domain/entity/organization"
)

type ClientRepository interface {
	Create(ctx context.Context, client *organization_entity.Client) error
	Count(ctx context.Context, conditions map[string]interface{}) (int64, error)
}
