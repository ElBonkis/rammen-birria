FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Producto #{n}" }
    price { 10_000 }
    description { "Delicioso" }
    available { true }

    trait :with_category do
      after(:create) do |product|
        product.categories << create(:category)
      end
    end
  end
end
