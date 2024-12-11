package organization_adapters

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	organization_testfixtures "github.com/troptropcontent/factoche/test/fixtures/organisation"
	testutils "github.com/troptropcontent/factoche/test/utils"
	"gorm.io/gorm"
)

func Test_clientRepository_Create(t *testing.T) {
	t.Run("When the client can be saved as is", func(t *testing.T) {
		testutils.WithinTransaction(t, func(db *gorm.DB) {
			ctx := context.Background()
			company := organization_testfixtures.Company

			companyRepo := NewCompanyRepository(db)

			err := companyRepo.Create(ctx, &company)
			if err != nil {
				t.Errorf("companyRepo.Create")
			}

			client := organization_testfixtures.NewClient(company.ID)

			clientRepo := NewClientRepository(db)
			numberOfClientBefore, _ := clientRepo.Count(ctx, nil)

			err = clientRepo.Create(ctx, client)
			assert.NoError(t, err)

			numberOfClientAfter, err := clientRepo.Count(ctx, nil)
			assert.NoError(t, err)
			assert.Equal(t, numberOfClientBefore+1, numberOfClientAfter)
			assert.Equal(t, client.CompanyID, company.ID)
		})
	})
	t.Run("When the client can not be saved as is", func(t *testing.T) {
		testutils.WithinTransaction(t, func(db *gorm.DB) {
			ctx := context.Background()

			client := organization_testfixtures.NewClient(0)

			clientRepo := NewClientRepository(db)

			err := clientRepo.Create(ctx, client)
			assert.Error(t, err)
		})
	})
}
