class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :role

  has_many :created_products, class_name: "Product", foreign_key: "created_by_id"
  has_many :created_categories, class_name: "Category", foreign_key: "created_by_id"
  has_many :activity_logs, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  
  def admin?
    role.name.include?("admin")
  end
  
  def regular_user?
    role.name.include?("user")
  end
end
