FactoryBot.define do
  factory :project, class: 'Organization::Project' do
    client { nil }
    retention_guarantee_rate { 0 }
    sequence(:name) { |n| "Project #{n}" }
  end
end
