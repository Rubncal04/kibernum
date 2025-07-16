module CacheInvalidation
  extend ActiveSupport::Concern

  private

  def invalidate_analytics_cache
    Rails.cache.delete_matched("most_purchased_by_category")
    Rails.cache.delete_matched("top_revenue_by_category")
    Rails.cache.delete_matched("purchases_by_granularity*")
  end

  def invalidate_product_cache
    Rails.cache.delete_matched("product_*")
    Rails.cache.delete_matched("products_index*")
  end

  def invalidate_customer_cache
    Rails.cache.delete_matched("customer_*")
    Rails.cache.delete_matched("customers_index*")
  end

  def invalidate_purchase_cache
    Rails.cache.delete_matched("purchases_index*")
    Rails.cache.delete_matched("purchases_by_granularity*")
  end
end
