FactoryBot.define do
  factory :customer do
    sequence(:name) { |n| "Customer #{n}" }
    sequence(:email) { |n| "customer#{n}@example.com" }
    phone { Faker::PhoneNumber.phone_number }
    address { Faker::Address.full_address }
    
    trait :with_purchases do
      after(:create) do |customer|
        create_list(:purchase, rand(1..3), customer: customer)
      end
    end
    
    trait :minimal do
      phone { nil }
      address { nil }
    end
  end
end
