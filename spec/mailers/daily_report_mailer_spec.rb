require 'rails_helper'

RSpec.describe DailyReportMailer, type: :mailer do
  let(:admin_user) { create(:user, :admin) }
  let(:date) { Date.current }
  let(:report_data) do
    {
      summary: {
        total_purchases: 5,
        total_revenue: 1250.50,
        total_quantity: 12,
        unique_customers: 3
      },
      top_products_by_revenue: { "Laptop" => 800.0, "Phone" => 450.50 },
      top_products_by_quantity: { "Laptop" => 4, "Phone" => 8 },
      purchases_by_category: { "Electronics" => 1250.50 },
      top_customers: { "John Doe, john@example.com" => 600.0 },
      detailed_purchases: [
        {
          id: 1,
          customer_name: "John Doe",
          customer_email: "john@example.com",
          product_name: "Laptop",
          quantity: 2,
          total_amount: 400.0,
          purchase_date: Time.current,
          categories: "Electronics"
        }
      ]
    }
  end

  describe 'daily_report_notification' do
    let(:mail) { DailyReportMailer.daily_report_notification(admin_user, report_data, date) }

    it 'renders the headers' do
      expect(mail.subject).to eq("Daily Purchase Report - #{date.strftime('%B %d, %Y')}")
      expect(mail.to).to eq([admin_user.email])
      expect(mail.from).to eq(['from@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Daily Purchase Report')
      expect(mail.body.encoded).to match('Total Purchases: 5')
      expect(mail.body.encoded).to match('Total Revenue: \$1,250.50')
      expect(mail.body.encoded).to match('Total Quantity: 12')
      expect(mail.body.encoded).to match('Unique Customers: 3')
    end

    it 'includes top products by revenue' do
      expect(mail.body.encoded).to match('Laptop.*\$800.00')
      expect(mail.body.encoded).to match('Phone.*\$450.50')
    end

    it 'includes top products by quantity' do
      expect(mail.body.encoded).to match('Laptop.*4')
      expect(mail.body.encoded).to match('Phone.*8')
    end

    it 'includes revenue by category' do
      expect(mail.body.encoded).to match('Electronics.*\$1,250.50')
    end

    it 'includes top customers' do
      expect(mail.body.encoded).to match('John Doe.*\$600.00')
    end

    it 'includes detailed purchases' do
      expect(mail.body.encoded).to match('John Doe.*john@example.com')
      expect(mail.body.encoded).to match('Laptop.*Electronics')
      expect(mail.body.encoded).to match('2.*\$400.00')
    end

    it 'handles empty data gracefully' do
      empty_report_data = {
        summary: { total_purchases: 0, total_revenue: 0, total_quantity: 0, unique_customers: 0 },
        top_products_by_revenue: {},
        top_products_by_quantity: {},
        purchases_by_category: {},
        top_customers: {},
        detailed_purchases: []
      }
      
      mail = DailyReportMailer.daily_report_notification(admin_user, empty_report_data, date)
      
      expect(mail.body.encoded).to match('Total Purchases: 0')
      expect(mail.body.encoded).to match('Total Revenue: \$0.00')
    end
  end
end
