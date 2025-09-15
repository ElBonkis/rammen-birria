Rails.application.routes.draw do
  scope defaults: { format: :json } do
    scope :api do
      scope :auth do
        post :register, to: "auth#register"
        post :login,    to: "auth#login"
        post :refresh,  to: "auth#refresh"
        delete :logout, to: "auth#logout"
        post "password/forgot", to: "password_resets#create"
        post "password/reset",  to: "password_resets#update"
      end

      post "uploads/direct", to: "uploads#direct"
      resources :products
      resources :categories
      resources :order_items
      resources :orders
      post "orders/preview", to: "orders#preview"

      get "/health", to: proc { [ 200, {}, [ "ok" ] ] }
    end
  end
end
