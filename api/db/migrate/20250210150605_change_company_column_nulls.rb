class ChangeCompanyColumnNulls < ActiveRecord::Migration[8.0]
  def change
    change_column_null :organization_companies, :rcs_city, false
    change_column_null :organization_companies, :rcs_number, false
    change_column_null :organization_companies, :vat_number, false
    change_column_null :organization_companies, :capital_amount, false
  end
end
