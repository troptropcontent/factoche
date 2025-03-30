class AddGeneralTermsAndConditionToOrganizationsCompanyConfigs < ActiveRecord::Migration[8.0]
  def change
    add_column :organization_company_configs, :general_terms_and_conditions, :text, null: false, default: '<h1>CONDITIONS GÉNÉRALES DE VENTE ET DE PRESTATION</h1>'
  end
end
