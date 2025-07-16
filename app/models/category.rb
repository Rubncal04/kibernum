class Category < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  has_and_belongs_to_many :products
  
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  
  scope :ordered, -> { order(:name) }
end
