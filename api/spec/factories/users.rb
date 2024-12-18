FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password_digest { "MyString" }
    last_login_at { "MyString" }
  end
end
