class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :price_with_discount, :quantity, :subtotal, presence: true
  validates :quantity, numericality: { greater_than: 0 }
end
