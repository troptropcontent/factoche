class PopulateIbanAndBicInFinancialTransactions < ActiveRecord::Migration[8.0]
  def up
    # Populate IBAN and BIC from related bank details
    # You'll need to adjust this query based on your actual data relationships
    execute <<-SQL
      UPDATE accounting_financial_transaction_details
      SET bank_detail_iban = (
        SELECT organization_bank_details.iban
        FROM organization_bank_details
        WHERE organization_bank_details.company_id = organization_bank_details.company_id
        LIMIT 1
      ),
      bank_detail_bic = (
        SELECT organization_bank_details.bic
        FROM organization_bank_details
        WHERE organization_bank_details.company_id = organization_bank_details.company_id
        LIMIT 1
      )
      WHERE bank_detail_iban IS NULL OR bank_detail_bic IS NULL;
    SQL
  end

  def down
    # Reset the columns to NULL
    execute <<-SQL
      UPDATE accounting_financial_transaction_details
      SET bank_detail_iban = NULL, bank_detail_bic = NULL;
    SQL
  end
end
