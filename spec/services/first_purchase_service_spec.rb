require 'rails_helper'

RSpec.describe FirstPurchaseService, type: :service do
  let(:admin_role) { create(:role, name: 'admin') }
  let(:product_creator) { create(:user, email: 'creator@example.com', role: admin_role) }
  let(:other_admin) { create(:user, email: 'other_admin@example.com', role: admin_role) }
  let(:product) { create(:product, created_by: product_creator) }
  let(:customer) { create(:customer) }
  let(:purchase) { create(:purchase, product: product, customer: customer) }
  let(:service) { FirstPurchaseService.new(purchase) }

  before do
    other_admin # Create another admin user
  end

  describe '#notify_if_first_purchase' do
    context 'when it is the first purchase for the product' do
      it 'sends the first purchase notification' do
        expect(FirstPurchaseMailer).to receive(:first_purchase_notification)
          .with(purchase)
          .and_return(double(deliver_later: true))
        
        service.notify_if_first_purchase
      end

      it 'logs the notification' do
        allow(FirstPurchaseMailer).to receive(:first_purchase_notification)
          .and_return(double(deliver_later: true))
        
        expect(Rails.logger).to receive(:info)
          .with("First purchase notification sent for product #{product.id}")
        
        service.notify_if_first_purchase
      end
    end

    context 'when it is not the first purchase for the product' do
      before do
        # Create another purchase for the same product first
        create(:purchase, product: product, customer: create(:customer))
      end

      it 'does not send the notification' do
        expect(FirstPurchaseMailer).not_to receive(:first_purchase_notification)
        
        service.notify_if_first_purchase
      end

      it 'logs that it is not the first purchase' do
        expect(Rails.logger).to receive(:info)
          .with("Not the first purchase for product #{product.id}, skipping notification")
        
        service.notify_if_first_purchase
      end
    end

    context 'when an error occurs' do
      before do
        allow(Product).to receive(:transaction).and_raise(StandardError, 'Database error')
      end

      it 'logs the error but does not raise it' do
        expect(Rails.logger).to receive(:error)
          .with("Error in FirstPurchaseService: Database error")
        
        expect { service.notify_if_first_purchase }.not_to raise_error
      end
    end
  end
end 