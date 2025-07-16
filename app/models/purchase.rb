class Purchase < ApplicationRecord
  belongs_to :customer
  belongs_to :product
  
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :purchase_date, presence: true
  
  scope :ordered, -> { order(purchase_date: :desc) }
  scope :by_date_range, ->(start_date, end_date) { 
    where(purchase_date: start_date.beginning_of_day..end_date.end_of_day) 
  }
  scope :by_customer, ->(customer_id) { where(customer_id: customer_id) }
  scope :by_product, ->(product_id) { where(product_id: product_id) }
  scope :by_category, ->(category_id) { 
    joins(product: :categories).where(categories: { id: category_id }) 
  }
  scope :today, -> { where(purchase_date: Date.current.beginning_of_day..Date.current.end_of_day) }
  scope :yesterday, -> { 
    where(purchase_date: 1.day.ago.beginning_of_day..1.day.ago.end_of_day) 
  }
  
  before_validation :set_purchase_date
  before_validation :calculate_total_amount
  
  private
  
  def set_purchase_date
    self.purchase_date ||= Time.current
  end

  def calculate_total_amount
    return unless product && quantity
    self.total_amount ||= product.price * quantity
  end
end
