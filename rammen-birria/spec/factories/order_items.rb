FactoryBot.define do
  factory :order_item do
    association :order
    association :product
    price_with_discount { product.price.to_d }
    quantity { 1 }
    subtotal { (price_with_discount * quantity).round(2) }
  end
end
