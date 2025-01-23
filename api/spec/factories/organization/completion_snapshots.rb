FactoryBot.define do
  factory :completion_snapshot, class: 'Organization::CompletionSnapshot' do
    project_version { nil }
    description { "MyString" }
  end
end
