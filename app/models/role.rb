class Role < ApplicationRecord
  has_many :users, dependent: :restrict_with_error
  
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
end
