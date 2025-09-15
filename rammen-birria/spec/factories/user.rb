FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@test.com" }
    password { "password123" }
    password_confirmation { "password123" }
    token_version { 1 }
    jti { SecureRandom.uuid }
  end
end