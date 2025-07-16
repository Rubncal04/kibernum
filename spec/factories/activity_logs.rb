FactoryBot.define do
  factory :activity_log do
    association :user
    association :scope, factory: :product
    action { 'create' }
    changes_data { { 'after' => { 'name' => 'Test Product', 'price' => 100.0 } } }

    trait :for_product do
      association :scope, factory: :product
      scope_type { 'Product' }
    end

    trait :for_category do
      association :scope, factory: :category
      scope_type { 'Category' }
    end

    trait :create_action do
      action { 'create' }
      changes_data { { 'after' => { 'name' => 'Test Item', 'description' => 'Test Description' } } }
    end

    trait :update_action do
      action { 'update' }
      changes_data { { 'before' => { 'name' => 'Old Name' }, 'after' => { 'name' => 'New Name' } } }
    end

    trait :destroy_action do
      action { 'destroy' }
      changes_data { { 'before' => { 'name' => 'Deleted Item', 'description' => 'Deleted Description' } } }
    end
  end
end
