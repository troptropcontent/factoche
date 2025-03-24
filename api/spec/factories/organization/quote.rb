FactoryBot.define do
  factory :quote, class: 'Organization::Quote' do
    company { nil }
    client { nil }
    sequence(:number) { |n| n }
    sequence(:name) { |n| "Quote #{n}" }
  end
end
