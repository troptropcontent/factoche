class FillVatNumberInOrganizationClients < ActiveRecord::Migration[8.0]
  def up
    Organization::Client.find_each do |client|
      # Using registration number as a default VAT number if not set
      client.update_column(:vat_number, client.registration_number)
    end
  end
end
