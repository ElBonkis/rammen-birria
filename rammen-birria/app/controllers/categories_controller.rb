class CategoriesController < ApplicationController
  before_action :set_category, only: %i[show update destroy]
  before_action :authenticate_access!, only: %i[create update destroy]

  def index
    @categories = Category.order(:name)
  end

  def show; end

  def create
    @category = Category.new(category_params)
    if @category.save
      render :show, status: :created, location: @category
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      render :show, status: :ok, location: @category
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy!
    head :no_content
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :description, :discount)
  end
end
