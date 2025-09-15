require "rails_helper"

RSpec.describe "Orders", type: :request do
  before { host! "www.example.com" }

  describe "POST /orders" do
    it "crea pedido aplicando el descuento máximo de categorías" do
      product = create(:product, price: 10_000)
      product.categories << create(:category, discount: 10)
      product.categories << create(:category, discount: 25)

      payload = {
        customer_name:  "Cliente",
        customer_phone: "3110000000",
        customer_address: "Calle 1",
        delivery_method: "delivery",
        payment_method:  "cash",
        items: [{ product_id: product.id, quantity: 2 }]
      }

      _user, headers = login!

      post "/api/orders",
           params: payload,
           headers: headers.merge("CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json"),
           as: :json



      expect(response).to have_http_status(:created)

      body = JSON.parse(response.body)
      expect(body["total"]).to eq("15000.0")
    end
  end
end
