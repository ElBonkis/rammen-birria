json.extract! item, :id, :quantity, :price_with_discount, :subtotal, :created_at, :updated_at
json.product do
  json.extract! item.product, :id, :name, :price
end
json.name item.product.name
