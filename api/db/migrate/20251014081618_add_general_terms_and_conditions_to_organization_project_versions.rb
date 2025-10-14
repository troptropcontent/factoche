class AddGeneralTermsAndConditionsToOrganizationProjectVersions < ActiveRecord::Migration[8.0]
  def change
    add_column :organization_project_versions, :general_terms_and_conditions, :string
  end
end
