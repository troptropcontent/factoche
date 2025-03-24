class AddVatNumberToOrganizationClients < ActiveRecord::Migration[8.0]
  def change
    add_column :organization_clients, :vat_number, :string
  end
end
