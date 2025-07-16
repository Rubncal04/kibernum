FactoryBot.define do
  factory :product_image do
    association :product
    sequence(:image_url) { |n| "https://example.com/images/product_#{n}.jpg" }
    alt_text { Faker::Lorem.words(number: 3).join(' ') }
    is_primary { false }
    order_index { rand(0..10) }
    
    trait :primary do
      is_primary { true }
      order_index { 0 }
    end
    
    trait :with_alt_text do
      alt_text { Faker::Lorem.sentence }
    end
    
    trait :first do
      order_index { 0 }
    end
    
    trait :last do
      order_index { 10 }
    end
  end
end
