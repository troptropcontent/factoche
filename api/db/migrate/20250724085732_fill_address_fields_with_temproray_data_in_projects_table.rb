class FillAddressFieldsWithTemprorayDataInProjectsTable < ActiveRecord::Migration[8.0]
  def change
    # Fill null values with temporary data and add NOT NULL constraints in one step
    change_column_null :organization_projects, :address_street, false, 'TEMPORARY STREET'
    change_column_null :organization_projects, :address_zipcode, false, '00000'
    change_column_null :organization_projects, :address_city, false, 'TEMPORARY CITY'
  end
end
