class MoveRetentionGuaranteeRateFromProjectToVersion < ActiveRecord::Migration[8.0]
  def change
    remove_column :organization_projects, :retention_guarantee_rate, :integer
    add_column :organization_project_versions, :retention_guarantee_rate, :integer
  end
end
