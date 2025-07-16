FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "category_#{n}" }
    description { "A test category" }
    association :created_by, factory: [:user, :admin]
    
    trait :electronics do
      name { "Electronics" }
      description { "Electronic devices and gadgets" }
    end
    
    trait :books do
      name { "Books" }
      description { "Books and publications" }
    end
    
    trait :clothing do
      name { "Clothing" }
      description { "Apparel and fashion items" }
    end
  end
end
