FactoryBot.define do
  factory :order do
    status { :pending }
    delivery_method { :pickup }
    payment_method { :cash }
    customer_name { "Cliente Prueba" }
    customer_phone { "3001234567" }
    customer_address { "Calle 123" }
    total { 0 }

    trait :with_items do
      transient do
        items_count { 2 }
        unit_price { 5000.to_d }
        quantity   { 2 }
      end

      after(:build) do |order, evaluator|
        evaluator.items_count.times do
          p = create(:product)
          price = evaluator.unit_price
          qty   = evaluator.quantity
          order.order_items << build(
            :order_item,
            order: order,
            product: p,
            price_with_discount: price,
            quantity: qty,
            subtotal: (price * qty).round(2)
          )
        end
        order.recalc_total!
      end
    end
  end
end
