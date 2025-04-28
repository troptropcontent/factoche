class AddTotalExclTaxAmountToOrganizationProjectVersions < ActiveRecord::Migration[8.0]
  def change
    add_column :organization_project_versions, :total_excl_tax_amount, :decimal, precision: 15, scale: 2, null: false
  end
end
