require 'rails_helper'

RSpec.describe DailyReportJob, type: :job do
  let(:admin_role) { create(:role, :admin) }
  let(:admin_user) { create(:user, :admin, role: admin_role) }
  let(:customer) { create(:customer) }
  let(:product) { create(:product, created_by: admin_user) }
  let(:yesterday) { Time.current.in_time_zone('America/Bogota').yesterday.to_date }

  before do
    create(:purchase, 
           customer: customer, 
           product: product, 
           quantity: 2, 
           total_amount: 100.0,
           purchase_date: yesterday.beginning_of_day + 2.hours)
    
    create(:purchase, 
           customer: customer, 
           product: product, 
           quantity: 1, 
           total_amount: 50.0,
           purchase_date: yesterday.beginning_of_day + 4.hours)
  end

  describe '#perform' do
    it 'generates daily report and sends emails to admin users' do
      expect {
        DailyReportJob.perform_now
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'sends email to all admin users' do
      admin_user2 = create(:user, :admin, role: admin_role)
      
      expect {
        DailyReportJob.perform_now
      }.to change { ActionMailer::Base.deliveries.count }.by(2)
      
      expect(ActionMailer::Base.deliveries.last.to).to include(admin_user.email)
      expect(ActionMailer::Base.deliveries.first.to).to include(admin_user2.email)
    end

    it 'includes correct report data in email' do
      DailyReportJob.perform_now
      
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to include("Daily Purchase Report")
      expect(email.body.encoded).to include("Total Purchases: 2")
      expect(email.body.encoded).to include("Total Revenue: $150.00")
      expect(email.body.encoded).to include("Total Quantity: 3")
      expect(email.body.encoded).to include("Unique Customers: 1")
    end

    it 'handles empty purchase data gracefully' do
      Purchase.destroy_all
      
      expect {
        DailyReportJob.perform_now
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
      
      email = ActionMailer::Base.deliveries.last
      expect(email.body.encoded).to include("Total Purchases: 0")
      expect(email.body.encoded).to include("Total Revenue: $0.00")
    end

    it 'only includes purchases from the specified date' do
      create(:purchase, 
             customer: customer, 
             product: product, 
             quantity: 5, 
             total_amount: 200.0,
             purchase_date: Time.current)
      
      DailyReportJob.perform_now
      
      email = ActionMailer::Base.deliveries.last
      expect(email.body.encoded).to include("Total Purchases: 2") # Only yesterday's purchases
      expect(email.body.encoded).to include("Total Revenue: $150.00") # Only yesterday's revenue
    end

    it 'logs success and error messages appropriately' do
      allow(Rails.logger).to receive(:info)
      allow(Rails.logger).to receive(:error)
      
      DailyReportJob.perform_now
      
      expect(Rails.logger).to have_received(:info).with("Starting DailyReportJob for #{Date.current}")
      expect(Rails.logger).to have_received(:info).with("Daily report emails sent to 1 admin users")
      expect(Rails.logger).to have_received(:info).with("DailyReportJob completed successfully for #{yesterday}")
    end

    it 'handles errors gracefully' do
      allow(User).to receive(:joins).and_raise(StandardError.new("Database error"))
      allow(Rails.logger).to receive(:error)
      
      expect {
        DailyReportJob.perform_now
      }.to raise_error(StandardError)
      
      expect(Rails.logger).to have_received(:error).with("DailyReportJob failed: Database error")
    end
  end

  describe 'report data generation' do
    let(:job) { DailyReportJob.new }
    
    it 'generates correct summary statistics' do
      report_data = job.send(:generate_daily_report, yesterday)
      
      expect(report_data[:summary][:total_purchases]).to eq(2)
      expect(report_data[:summary][:total_revenue]).to eq(150.0)
      expect(report_data[:summary][:total_quantity]).to eq(3)
      expect(report_data[:summary][:unique_customers]).to eq(1)
    end

    it 'includes top products by revenue' do
      report_data = job.send(:generate_daily_report, yesterday)
      
      expect(report_data[:top_products_by_revenue]).to include(product.name => 150.0)
    end

    it 'includes top products by quantity' do
      report_data = job.send(:generate_daily_report, yesterday)
      
      expect(report_data[:top_products_by_quantity]).to include(product.name => 3)
    end

    it 'includes detailed purchase information' do
      report_data = job.send(:generate_daily_report, yesterday)
      
      expect(report_data[:detailed_purchases].length).to eq(2)
      expect(report_data[:detailed_purchases].first[:customer_name]).to eq(customer.name)
      expect(report_data[:detailed_purchases].first[:product_name]).to eq(product.name)
    end
  end
end
