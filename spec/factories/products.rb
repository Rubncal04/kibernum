FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    description { "A test product description" }
    price { 99.99 }
    stock { 10 }
    association :created_by, factory: [:user, :admin]
    
    trait :out_of_stock do
      stock { 0 }
    end
    
    trait :low_stock do
      stock { 3 }
    end
    
    trait :expensive do
      price { 999.99 }
    end
    
    trait :cheap do
      price { 9.99 }
    end
    
    trait :with_categories do
      after(:create) do |product|
        product.categories << create(:category)
      end
    end
  end
end
