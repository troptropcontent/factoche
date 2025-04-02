FactoryBot.define do
  factory :draft_order, class: 'Organization::DraftOrder' do
    company { nil }
    client { nil }
    sequence(:number) { |n| n }
    sequence(:name) { |n| "DraftOrder #{n}" }
  end
end
