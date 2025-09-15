FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Categoria #{n}" }
    discount { 0 }
    description { "Categoria de prueba" }
  end
end
