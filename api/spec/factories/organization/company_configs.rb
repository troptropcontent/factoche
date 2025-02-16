FactoryBot.define do
  factory :company_config, class: 'Organization::CompanyConfig' do
    company { }
    settings { Organization::CompanyConfig::DEFAULT_SETTINGS }
  end
end
