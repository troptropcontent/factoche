FactoryBot.define do
  factory :project_version, class: 'Organization::ProjectVersion' do
    project { nil }
    retention_guarantee_rate { 500 }
    number { 1 }
  end
end
