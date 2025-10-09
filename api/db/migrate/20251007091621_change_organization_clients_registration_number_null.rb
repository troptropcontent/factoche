class ChangeOrganizationClientsRegistrationNumberNull < ActiveRecord::Migration[8.0]
  def change
    change_column_null :organization_clients, :registration_number, true
  end
end
