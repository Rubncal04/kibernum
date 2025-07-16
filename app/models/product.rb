class Product < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  has_and_belongs_to_many :categories
  has_many :purchases, dependent: :destroy
  has_many :product_images, dependent: :destroy
  
  validates :name, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  scope :ordered, -> { order(:name) }
  scope :in_stock, -> { where('stock > 0') }
  scope :by_category, ->(category_id) { joins(:categories).where(categories: { id: category_id }) }
  scope :with_purchases, -> { joins(:purchases).distinct }
  scope :most_purchased, -> { 
    joins(:purchases)
    .group(:id)
    .order('SUM(purchases.quantity) DESC')
  }
  scope :top_revenue, -> { 
    joins(:purchases)
    .group(:id)
    .order('SUM(purchases.total_amount) DESC')
  }
  
  def available?
    stock > 0
  end
  
  def low_stock?
    stock <= 5
  end
  
  def total_purchases
    purchases.sum(:quantity)
  end
  
  def total_revenue
    purchases.sum(:total_amount)
  end
  
  def primary_image
    product_images.primary.first
  end
  
  def first_purchase_date
    purchases.minimum(:purchase_date)
  end
end
