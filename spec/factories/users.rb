FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:name) { |n| "User #{n}" }
    password { "password123" }
    password_confirmation { "password123" }
    association :role
    
    trait :admin do
      association :role, :admin
    end
    
    trait :regular_user do
      association :role, :user
    end
  end
end
