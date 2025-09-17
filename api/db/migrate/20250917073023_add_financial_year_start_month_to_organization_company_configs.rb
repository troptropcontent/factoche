class AddFinancialYearStartMonthToOrganizationCompanyConfigs < ActiveRecord::Migration[8.0]
  def change
    add_column :organization_company_configs, :financial_year_start_month, :integer, default: 1, null: false
  end
end
