json.array! @orders do |order|
  json.extract! order, :id, :code, :status, :customer_name, :customer_phone, :total, :created_at
  json.items_count order.order_items.size
end
