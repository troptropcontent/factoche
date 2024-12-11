package organization_adapters

import (
	"context"

	organization_entity "github.com/troptropcontent/factoche/internal/domain/entity/organization"
	organization_repository "github.com/troptropcontent/factoche/internal/domain/repository/organization"
	organization_model "github.com/troptropcontent/factoche/internal/infrastructure/database/postgres/models/organization"
	"gorm.io/gorm"
)

type clientAdapter struct {
	db *gorm.DB
}

func NewClientRepository(db *gorm.DB) organization_repository.ClientRepository {
	return &clientAdapter{db: db}
}

func (r *clientAdapter) Create(ctx context.Context, client *organization_entity.Client) error {
	model := &organization_model.Client{}
	model.FromEntity(client)

	result := r.db.WithContext(ctx).Create(model)
	if result.Error != nil {
		return result.Error
	}
	return nil
}

func (r *clientAdapter) Count(ctx context.Context, conditions map[string]interface{}) (int64, error) {
	var count int64
	query := r.db.Model(&organization_model.Client{})
	if len(conditions) > 0 {
		query = query.Where(conditions)
	}
	result := query.Count(&count)
	return count, result.Error
}
