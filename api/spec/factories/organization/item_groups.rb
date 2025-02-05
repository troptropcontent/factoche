FactoryBot.define do
  factory :item_group, class: 'Organization::ItemGroup' do
    project_version { nil }
    sequence(:name) { |n| "Item Group #{n}" }
    sequence(:position) { |n| n }
  end
end
