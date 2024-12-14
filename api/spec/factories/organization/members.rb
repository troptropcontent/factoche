FactoryBot.define do
  factory :member, class: 'Organization::Member' do
    user { nil }
    company { nil }
  end
end
