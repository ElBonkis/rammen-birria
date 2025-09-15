class Product < ApplicationRecord
  has_one_attached :image
  has_and_belongs_to_many :categories

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  validate :validate_image

  def discount_percent
    if association(:categories).loaded?
      (categories.map { |c| c.discount.to_i }.max || 0).clamp(0, 100)
    else
      max_discount
    end
  end

  def max_discount
    categories.maximum(:discount).to_i.clamp(0, 100)
  end

  def price_with_discount
    (price.to_d * (100 - discount_percent) / 100.0).round(2)
  end

  private

  def validate_image
    return unless image.attached?

    if image.byte_size > 5.megabytes
      errors.add(:image, "es demasiado grande (máximo 5 MB)")
    end

    ok = %w[image/jpeg image/png image/webp]
    errors.add(:image, "debe ser JPG, PNG o WEBP") unless ok.include?(image.content_type)
  end
end
