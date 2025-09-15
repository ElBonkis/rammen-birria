require "rails_helper"

RSpec.describe OrderItem, type: :model do
  it { is_expected.to belong_to(:order) }
  it { is_expected.to belong_to(:product) }

  it { is_expected.to validate_presence_of(:price_with_discount) }
  it { is_expected.to validate_presence_of(:quantity) }
  it { is_expected.to validate_presence_of(:subtotal) }
  it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0) }

  it "calcula subtotal coherente" do
    item = build(:order_item, price_with_discount: 1200, quantity: 3)
    expect(item.subtotal).to eq(3600)
  end
end
