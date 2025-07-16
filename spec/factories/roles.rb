FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "role_#{n}" }
    description { "A test role" }
    
    trait :admin do
      sequence(:name) { |n| "admin_#{n}" }
      description { "System administrator" }
    end
    
    trait :user do
      sequence(:name) { |n| "user_#{n}" }
      description { "Regular user" }
    end
  end
end
