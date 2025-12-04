# frozen_string_literal: true

FactoryBot.define do
  factory :discount, class: "Organization::Discount" do
    association :project_version, factory: :project_version

    kind { "fixed_amount" }
    value { 100 }
    amount { 100 }
    position { 1 }
    original_discount_uuid { SecureRandom.uuid }
    name { "Earlybird discount" }

    trait :fixed_amount do
      kind { "fixed_amount" }
      value { 100 }
      amount { 100 }
    end

    trait :percentage do
      kind { "percentage" }
      value { 0.10 }
      amount { 1000 }
    end
  end
end
