class MakeTypeNotNullInOrganisationProjects < ActiveRecord::Migration[8.0]
  def change
    change_column_null :organization_projects, :type, false
  end
end
