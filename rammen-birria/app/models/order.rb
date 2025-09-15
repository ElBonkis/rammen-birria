class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy

  enum :status,          { pending: 0, confirmed: 1, in_progress: 2, delivered: 3, cancelled: 4 }
  enum :delivery_method, { pickup: 0, delivery: 1 }
  enum :payment_method,  { cash: 0,   card: 1,  transfer: 2 }

  before_validation :set_code, on: :create

  validates :code, presence: true, uniqueness: true
  validates :customer_name, :customer_phone, presence: true
  validates :total, numericality: { greater_than_or_equal_to: 0 }


  def recalc_total!(persist: false)
    self.total = order_items.to_a.sum { |it| it.subtotal.to_d }.round(2)
    save! if persist || (persisted? && changed?)
    total
  end

  private

  def set_code
    self.code ||= loop do
      c = "RB-#{SecureRandom.hex(3).upcase}"
      break c unless self.class.exists?(code: c)
    end
  end
end
