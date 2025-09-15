require "rails_helper"

RSpec.describe Category, type: :model do
  it { is_expected.to have_and_belong_to_many(:products) }
  it { is_expected.to validate_presence_of(:name) }

  it "puede tener discount opcional" do
    c = build(:category, discount: nil)
    expect(c).to be_valid
  end

  it "persiste correctamente" do
    c = create(:category, name: "Promos", discount: 15)
    expect(c.id).to be_present
    expect(c.discount).to eq(15)
  end
end