class AddReferenceToBankDetailsInProjectVersion < ActiveRecord::Migration[8.0]
  def change
    add_reference :organization_project_versions, :bank_detail, foreign_key: { to_table: :organization_bank_details }
  end
end
