json.extract! product, :id, :name, :price, :description, :available, :created_at, :updated_at

if product.image.attached?
  json.image_url rails_blob_path(product.image, only_path: true)
else
  json.image_url nil
end

json.price_with_discount product.price_with_discount
json.discount_percent product.discount_percent

json.categories product.categories do |category|
  json.extract! category, :id, :name
end
