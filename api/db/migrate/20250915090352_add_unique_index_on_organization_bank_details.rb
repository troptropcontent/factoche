class AddUniqueIndexOnOrganizationBankDetails < ActiveRecord::Migration[8.0]
  def change
    add_index :organization_bank_details, [ :company_id, :iban ], unique: true
  end
end
