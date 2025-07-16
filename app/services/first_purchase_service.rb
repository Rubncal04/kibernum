class FirstPurchaseService
  def initialize(purchase)
    @purchase = purchase
    @product = purchase.product
  end

  def notify_if_first_purchase
    # Use database-level locking to prevent race conditions
    Product.transaction do
      # Lock the product row to prevent concurrent access
      product = Product.lock.find(@product.id)
      
      # Check if this is the first purchase for this product
      if product.purchases.count == 1 && product.purchases.first.id == @purchase.id
        # This is indeed the first purchase, send notification
        send_first_purchase_notification
        Rails.logger.info "First purchase notification sent for product #{@product.id}"
      else
        Rails.logger.info "Not the first purchase for product #{@product.id}, skipping notification"
      end
    end
  rescue => e
    Rails.logger.error "Error in FirstPurchaseService: #{e.message}"
    # Don't raise the error to avoid breaking the purchase creation
  end

  private

  def send_first_purchase_notification
    # Send email asynchronously to avoid blocking the purchase process
    FirstPurchaseMailer.first_purchase_notification(@purchase).deliver_later
  end
end 