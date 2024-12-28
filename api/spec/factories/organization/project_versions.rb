FactoryBot.define do
  factory :project_version, class: 'Organization::ProjectVersion' do
    project { nil }
    number { 1 }
  end
end
