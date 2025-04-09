FactoryBot.define do
  factory :project, class: 'Organization::Project' do
    client { nil }
    sequence(:name) { |n| "Project #{n}" }
    sequence(:number) { |n| n }
  end
end
