FactoryBot.define do
  factory :project_version, class: 'Organization::ProjectVersion' do
    project { nil }
    retention_guarantee_rate { 0.05 }
    total_excl_tax_amount { 0.0 }
    number { 1 }
  end
end
