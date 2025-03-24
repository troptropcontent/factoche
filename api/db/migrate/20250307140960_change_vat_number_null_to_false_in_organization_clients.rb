class ChangeVatNumberNullToFalseInOrganizationClients < ActiveRecord::Migration[8.0]
  def change
    change_column_null :organization_clients, :vat_number, false
  end
end
