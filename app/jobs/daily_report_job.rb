class DailyReportJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting DailyReportJob for #{Date.current}"

    yesterday = Time.current.in_time_zone('America/Bogota').yesterday.to_date

    report_data = generate_daily_report(yesterday)

    send_daily_report_email(report_data, yesterday)
    
    Rails.logger.info "DailyReportJob completed successfully for #{yesterday}"
  rescue => e
    Rails.logger.error "DailyReportJob failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end

  private

  def generate_daily_report(date)
    start_date = date.beginning_of_day
    end_date = date.end_of_day
    
    purchases = Purchase.includes(:customer, :product, product: :categories)
                       .where(purchase_date: start_date..end_date)
    
    purchases_by_product = purchases.group_by(&:product).transform_keys do |product|
      product.name
    end.transform_values do |purchases_array|
      purchases_array.map do |purchase|
        {
          id: purchase.id,
          customer_name: purchase.customer.name,
          customer_email: purchase.customer.email,
          quantity: purchase.quantity,
          total_amount: purchase.total_amount,
          purchase_date: purchase.purchase_date
        }
      end
    end
    
    total_purchases = purchases.count
    total_revenue = purchases.sum(:total_amount)
    total_quantity = purchases.sum(:quantity)
    
    top_products_by_revenue = purchases.joins(:product)
                                      .group('products.id, products.name')
                                      .order('SUM(purchases.total_amount) DESC')
                                      .limit(5)
                                      .sum(:total_amount)
    
    top_products_by_quantity = purchases.joins(:product)
                                       .group('products.id, products.name')
                                       .order('SUM(purchases.quantity) DESC')
                                       .limit(5)
                                       .sum(:quantity)
    
    purchases_by_category = purchases.joins(product: :categories)
                                    .group('categories.name')
                                    .sum(:total_amount)
    
    unique_customers = purchases.distinct.count(:customer_id)
    top_customers = purchases.joins(:customer)
                            .group('customers.id, customers.name, customers.email')
                            .order('SUM(purchases.total_amount) DESC')
                            .limit(5)
                            .sum(:total_amount)
    
    {
      date: date,
      summary: {
        total_purchases: total_purchases,
        total_revenue: total_revenue,
        total_quantity: total_quantity,
        unique_customers: unique_customers
      },
      top_products_by_revenue: top_products_by_revenue,
      top_products_by_quantity: top_products_by_quantity,
      purchases_by_category: purchases_by_category,
      top_customers: top_customers,
      purchases_by_product: purchases_by_product,
      detailed_purchases: purchases.map do |purchase|
        {
          id: purchase.id,
          customer_name: purchase.customer.name,
          customer_email: purchase.customer.email,
          product_name: purchase.product.name,
          quantity: purchase.quantity,
          total_amount: purchase.total_amount,
          purchase_date: purchase.purchase_date,
          categories: purchase.product.categories.pluck(:name).join(', ')
        }
      end
    }
  end

  def send_daily_report_email(report_data, date)
    admin_users = User.joins(:role).where(roles: { name: 'admin' })
    
    if admin_users.empty?
      Rails.logger.warn "No admin users found to send daily report"
      return
    end
    
    admin_users.each do |admin|
      DailyReportMailer.daily_report_notification(admin, report_data, date).deliver_later
    end
    
    Rails.logger.info "Daily report emails sent to #{admin_users.count} admin users"
  end
end
