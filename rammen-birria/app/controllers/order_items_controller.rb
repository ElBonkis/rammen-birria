class OrderItemsController < ApplicationController
  before_action :set_order_item, only: %i[ show update destroy ]

  def index
    @order_items = OrderItem.all
  end

  def show
  end

  def create
    @order_item = OrderItem.new(order_item_params)

    if @order_item.save
      render :show, status: :created, location: @order_item
    else
      render json: @order_item.errors, status: :unprocessable_entity
    end
  end

  def update
    if @order_item.update(order_item_params)
      render :show, status: :ok, location: @order_item
    else
      render json: @order_item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @order_item.destroy!
  end

  private
    def set_order_item
      @order_item = OrderItem.find(params.expect(:id))
    end

    def order_item_params
      params.expect(order_item: [ :order_id, :product_id, :price_with_discount, :quantity, :subtotal ])
    end
end
