class ChangeOriginalQuoteVersionIdOfOrganizationProjectsIntoOriginalProjectVersionId < ActiveRecord::Migration[8.0]
  def change
    # Remove the old foreign key and column
    remove_reference :organization_projects, :original_quote_version,
                    foreign_key: { to_table: :organization_project_versions }

    # Add the new reference
    add_reference :organization_projects, :project_version,
                 foreign_key: { to_table: :organization_project_versions },
                 null: true
  end
end
