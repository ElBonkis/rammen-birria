json.extract! @order, :id, :code, :status, :customer_name, :customer_phone, :customer_address,
                     :delivery_method, :payment_method, :total, :created_at, :updated_at
json.items @order.order_items, partial: "orders/order_item", as: :item
