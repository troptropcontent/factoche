FactoryBot.define do
  factory :item_group, class: 'Organization::ItemGroup' do
    project_version { nil }
    name { "MyString" }
    sequence(:position) { |n| n }
  end
end
