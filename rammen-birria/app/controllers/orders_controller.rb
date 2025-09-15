class OrdersController < ApplicationController
  before_action :authenticate_access!, only: %i[index update]
  skip_before_action :verify_authenticity_token, only: :create

  def create
    permitted = params.permit(
      :customer_name, :customer_phone, :customer_address,
      :delivery_method, :payment_method,
      items: [:product_id, :quantity]
    )

    items = Array(permitted.delete(:items))

    ActiveRecord::Base.transaction do
      @order = Order.new(normalize_order_enums(permitted))

      items.each do |it|
        it = it.to_h.symbolize_keys

        product = Product.find(it[:product_id])
        qty     = Integer(it[:quantity] || 1)
        qty     = 1 if qty <= 0

        price_with_discount = product.price_with_discount
        subtotal = (price_with_discount * qty).round(2)

        @order.order_items.build(
          product: product,
          price_with_discount: price_with_discount,
          quantity: qty,
          subtotal: subtotal
        )
      end

      @order.recalc_total!

      if @order.save
        render :show, status: :created
      else
        render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def preview
    permitted = params.permit(items: [:product_id, :quantity])
    items = Array(permitted[:items])

    computed = []
    total = 0.to_d

    items.each do |it|
      it = it.to_h.symbolize_keys
      product = Product.find(it[:product_id])
      qty     = Integer(it[:quantity] || 1)
      qty     = 1 if qty <= 0

      unit_price = product.price
      price_with_discount = product.price_with_discount
      subtotal = (price_with_discount * qty).round(2)
      subtotal     = (unit_price * qty).round(2)
      total       += subtotal

      computed << {
        product_id:        product.id,
        name:              product.name,
        base_price:        unit_price,
        discount_percent:  product.max_discount,
        unit_price:        price_with_discount,
        quantity:          qty,
        subtotal:          subtotal
      }
    end

    render json: { items: computed, total: total }, status: :ok
  end

  def index
    @orders = Order.includes(order_items: :product).order(created_at: :desc)
    @orders = @orders.where(status: params[:status]) if params[:status].present?
    render :index
  end

  def show
    @order = Order.includes(order_items: :product).find(params[:id])
    render :show
  end

  def update
    @order = Order.find(params[:id])
    st = params[:status].presence
    if st && Order.statuses.key?(st)
      @order.update!(status: st)
      render :show
    else
      render json: { error: "Estado inválido" }, status: :unprocessable_entity
    end
  end

  private

  def normalize_order_enums(hashlike)
    h = hashlike.to_h.symbolize_keys
    h[:delivery_method] = normalize_enum(h[:delivery_method], Order.delivery_methods)
    h[:payment_method]  = normalize_enum(h[:payment_method],  Order.payment_methods)
    h
  end

  def normalize_enum(value, mapping)
    return value if value.is_a?(Integer) || value.blank?
    key = value.to_s
    mapping.key?(key) ? key : value
  end

  def require_auth!
    head :forbidden unless current_user.present?
  end
end
