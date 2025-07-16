require 'rails_helper'

RSpec.describe FirstPurchaseMailer, type: :mailer do
  describe 'first_purchase_notification' do
    let(:admin_role) { create(:role, name: 'admin') }
    let(:product_creator) { create(:user, email: 'creator@example.com', role: admin_role) }
    let(:other_admin) { create(:user, email: 'other_admin@example.com', role: admin_role) }
    let(:product) { create(:product, created_by: product_creator) }
    let(:customer) { create(:customer) }
    let(:purchase) { create(:purchase, product: product, customer: customer) }
    let(:mail) { FirstPurchaseMailer.first_purchase_notification(purchase) }

    before do
      # Create another admin user to test CC functionality
      other_admin
    end

    it 'renders the headers' do
      expect(mail.subject).to eq("¡Primera compra del producto: #{product.name}!")
      expect(mail.to).to eq([product_creator.email])
      expect(mail.cc).to eq([other_admin.email])
      expect(mail.from).to eq(['noreply@kibernum-ecommerce.com'])
    end

    it 'renders the body' do
      # Check HTML part
      expect(mail.html_part.body.encoded).to match(product_creator.name)
      expect(mail.html_part.body.encoded).to match(product.name)
      expect(mail.html_part.body.encoded).to match(customer.name)
      expect(mail.html_part.body.encoded).to match(purchase.quantity.to_s)
      expect(mail.html_part.body.encoded).to match(purchase.total_amount.to_s)
      
      # Check text part
      expect(mail.text_part.body.encoded).to match(product_creator.name)
      expect(mail.text_part.body.encoded).to match(product.name)
      expect(mail.text_part.body.encoded).to match(customer.name)
      expect(mail.text_part.body.encoded).to match(purchase.quantity.to_s)
      expect(mail.text_part.body.encoded).to match(purchase.total_amount.to_s)
    end

    it 'includes product information' do
      # Check HTML part
      expect(mail.html_part.body.encoded).to match(product.description)
      expect(mail.html_part.body.encoded).to match(product.price.to_s)
      
      # Check text part
      expect(mail.text_part.body.encoded).to match(product.description)
      expect(mail.text_part.body.encoded).to match(product.price.to_s)
    end

    it 'includes customer information' do
      # Check both HTML and text parts
      expect(mail.html_part.body.encoded).to match(customer.email)
      expect(mail.html_part.body.encoded).to match(customer.phone)
      expect(mail.html_part.body.encoded).to match(customer.address)
      
      expect(mail.text_part.body.encoded).to match(customer.email)
      expect(mail.text_part.body.encoded).to match(customer.phone)
      expect(mail.text_part.body.encoded).to match(customer.address)
    end

    it 'includes purchase details' do
      # Check HTML part
      expect(mail.html_part.body.encoded).to match(purchase.purchase_date.strftime('%d/%m/%Y'))
      
      # Check text part
      expect(mail.text_part.body.encoded).to match(purchase.purchase_date.strftime('%d/%m/%Y'))
    end
  end
end
