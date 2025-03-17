class PopulateTypeInOrganisationProjects < ActiveRecord::Migration[8.0]
  def up
    # Assuming 'StandardProject' is your default type
    # Replace with your actual default type class name
    execute <<-SQL
      UPDATE organization_projects
      SET type = 'Organization::Project'
      WHERE type IS NULL
    SQL
  end

  def down
    execute <<-SQL
      UPDATE organization_projects
      SET type = NULL
    SQL
  end
end
