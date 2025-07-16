FactoryBot.define do
  factory :purchase do
    association :customer
    association :product
    quantity { rand(1..5) }
    purchase_date { Faker::Time.between(from: 1.month.ago, to: Time.current) }

    trait :today do
      purchase_date { Time.current }
    end

    trait :yesterday do
      purchase_date { 1.day.ago }
    end

    trait :high_quantity do
      quantity { rand(10..50) }
    end

    trait :recent do
      purchase_date { Faker::Time.between(from: 1.week.ago, to: Time.current) }
    end
  end
end
