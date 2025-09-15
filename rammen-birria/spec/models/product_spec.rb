# spec/models/product_spec.rb
require "rails_helper"

RSpec.describe Product, type: :model do
  it { is_expected.to have_and_belong_to_many(:categories) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_numericality_of(:price).is_greater_than_or_equal_to(0) }

  describe "#discount_percent" do
    let(:product) { create(:product, price: 10_000) }

    it "es 0 cuando no hay categorías" do
      expect(product.discount_percent).to eq(0)
    end

    it "toma el máximo descuento entre categorías" do
      product.categories << create(:category, discount: 10)
      product.categories << create(:category, discount: 25)
      expect(product.discount_percent).to eq(25)
    end

    it "clamp a 0..100 cuando hay valores fuera de rango" do
      product.categories << create(:category, discount: -5)
      expect(product.discount_percent).to eq(0)

      product.categories = []
      product.categories << create(:category, discount: 120)
      expect(product.discount_percent).to eq(100)
    end

    it "funciona también con categorías pre-cargadas (sin N+1)" do
      product.categories << create(:category, discount: 15)
      product.categories << create(:category, discount: 30)
      p = Product.includes(:categories).find(product.id)
      expect(p.association(:categories)).to be_loaded
      expect(p.discount_percent).to eq(30)
    end
  end

  describe "#price_with_discount" do
    let(:product) { create(:product, price: 10_000) }

    it "devuelve el mismo precio si no hay descuento" do
      expect(product.price_with_discount).to eq(10_000)
    end

    it "aplica el mayor descuento" do
      product.categories << create(:category, discount: 10)
      product.categories << create(:category, discount: 25)
      expect(product.price_with_discount).to eq(7_500) # 10_000 * 0.75
    end

    it "soporta 100% (queda en 0)" do
      product.categories << create(:category, discount: 100)
      expect(product.price_with_discount).to eq(0)
    end
  end
end
