class ProductImage < ApplicationRecord
  belongs_to :product
  
  validates :image_url, presence: true
  validates :order_index, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :is_primary, inclusion: { in: [true, false] }
  
  scope :ordered, -> { order(:order_index) }
  scope :primary, -> { where(is_primary: true) }
  scope :by_product, ->(product_id) { where(product_id: product_id) }
  
  before_save :ensure_single_primary_per_product, if: :is_primary?
  
  private
  
  def ensure_single_primary_per_product
    ProductImage.where(product: product, is_primary: true)
                .where.not(id: id)
                .update_all(is_primary: false)
  end
end
