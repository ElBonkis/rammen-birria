class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]
  before_action :set_categories, only: %i[new edit create update]
  before_action :authenticate_access!, only: %i[create update destroy]

  def index
    scope = Product.includes(:categories).order(created_at: :desc)
    if params[:category_id].present?
      scope = scope.joins(:categories).where(categories: { id: params[:category_id] })
    end
    @products = scope.distinct
  end

  def show; end

  def new
    @product = Product.new
  end

  def edit; end

  def create
    @product = Product.new(product_params)
    @product.image.attach(params[:image_signed_id]) if params[:image_signed_id].present?

    if @product.save
      render :show, status: :created
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @product.assign_attributes(product_params)
    @product.image.attach(params[:image_signed_id]) if params[:image_signed_id].present?

    if @product.save
      render :show
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy!
    head :no_content
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def set_categories
    @categories = Category.order(:name)
  end

  def product_params
    params.require(:product)
          .permit(:name, :price, :description, :available, category_ids: [])
  end
end
