class AddPostedAndPostedAtToOrganizationProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :organization_projects, :posted, :boolean, null: false, default: false
    add_column :organization_projects, :posted_at, :datetime
  end
end
