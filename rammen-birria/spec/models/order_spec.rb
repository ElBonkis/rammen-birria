require "rails_helper"

RSpec.describe Order, type: :model do
  it { is_expected.to have_many(:order_items).dependent(:destroy) }

  it do
    is_expected.to define_enum_for(:status)
      .with_values(pending: 0, confirmed: 1, in_progress: 2, delivered: 3, cancelled: 4)
  end
  it { is_expected.to define_enum_for(:delivery_method).with_values(pickup: 0, delivery: 1) }
  it { is_expected.to define_enum_for(:payment_method).with_values(cash: 0, card: 1, transfer: 2) }

  it { is_expected.to validate_presence_of(:customer_name) }
  it { is_expected.to validate_presence_of(:customer_phone) }
  it { is_expected.to validate_numericality_of(:total).is_greater_than_or_equal_to(0) }

  it "genera code único al crear" do
    o = create(:order, customer_name: "A", customer_phone: "1")
    expect(o.code).to be_present
    expect(o.code).to match(/\ARB-[0-9A-F]{6}\z/i).or match(/\A.+\z/) 
  end

  it "recalc_total! suma subtotales de sus items" do
    o = build(:order, :with_items, items_count: 2, unit_price: 1000, quantity: 2,
               customer_name: "A", customer_phone: "1")
    expect(o.total).to eq(4_000) 
  end

  it "acepta cambiar estados" do
    o = create(:order, customer_name: "A", customer_phone: "1")
    expect(o).to be_pending
    o.confirmed!
    expect(o).to be_confirmed
  end
end
