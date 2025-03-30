class DropDefaultOnOrganizationCompanyConfigs < ActiveRecord::Migration[8.0]
  def change
    change_column_default :organization_company_configs, :general_terms_and_conditions, from: '<h1>CONDITIONS GÉNÉRALES DE VENTE ET DE PRESTATION</h1>', to: nil
    change_column_default :organization_company_configs, :default_vat_rate, from: 0.20, to: nil
    change_column_default :organization_company_configs, :payment_term_days, from: 30, to: nil
    change_column_default :organization_company_configs, :payment_term_accepted_methods, from: [ "transfer" ], to: []
  end
end
