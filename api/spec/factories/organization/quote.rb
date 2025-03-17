FactoryBot.define do
  factory :quote, class: 'Organization::Quote' do
    client { nil }
    sequence(:name) { |n| "Quote #{n}" }
  end
end
