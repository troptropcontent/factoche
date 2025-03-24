class AddQuoteVersionReferenceToOrganizationProjects < ActiveRecord::Migration[8.0]
  def change
    add_reference :organization_projects, :original_quote_version,
                  foreign_key: { to_table: :organization_project_versions },
                  null: true  # Important: must be nullable
  end
end
