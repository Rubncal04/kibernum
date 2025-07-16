class Customer < ApplicationRecord
  has_many :purchases, dependent: :destroy
  
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, uniqueness: true, 
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, length: { maximum: 20 }, allow_blank: true
  validates :address, length: { maximum: 500 }, allow_blank: true
  
  scope :ordered, -> { order(:name) }
  scope :with_purchases, -> { joins(:purchases).distinct }
  scope :by_email, ->(email) { where(email: email) }
  
  def total_purchases
    purchases.count
  end
  
  def total_spent
    purchases.sum(&:total_amount)
  end
  
  def last_purchase_date
    purchases.maximum(:purchase_date)
  end
end
