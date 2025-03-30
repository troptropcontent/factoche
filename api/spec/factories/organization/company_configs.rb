FactoryBot.define do
  factory :company_config, class: 'Organization::CompanyConfig' do
    company { }
    settings { Organization::CompanyConfig::DEFAULT_SETTINGS }
    default_vat_rate { 0.20 }
    payment_term_days { 30 }
    payment_term_accepted_methods { [ "transfer" ] }
    general_terms_and_conditions { '<h1>CONDITIONS GÉNÉRALES DE VENTE ET DE PRESTATION</h1>' }
  end
end
