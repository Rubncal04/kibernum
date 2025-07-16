require 'rails_helper'

RSpec.describe Purchase, type: :model do
  describe 'associations' do
    it 'belongs to customer' do
      expect(Purchase.reflect_on_association(:customer).macro).to eq :belongs_to
    end

    it 'belongs to product' do
      expect(Purchase.reflect_on_association(:product).macro).to eq :belongs_to
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      purchase = build(:purchase)
      expect(purchase).to be_valid
    end

    it 'is not valid without quantity' do
      purchase = build(:purchase, quantity: nil)
      expect(purchase).not_to be_valid
      expect(purchase.errors[:quantity]).to include("can't be blank")
    end

    it 'is not valid without total_amount' do
      # Skip callbacks by using skip_callback temporarily
      Purchase.skip_callback(:validation, :before, :calculate_total_amount)
      purchase = build(:purchase, total_amount: nil)
      expect(purchase).not_to be_valid
      expect(purchase.errors[:total_amount]).to include("can't be blank")
      # Restore callback
      Purchase.set_callback(:validation, :before, :calculate_total_amount)
    end

    it 'is not valid without purchase_date' do
      # Skip callbacks by using skip_callback temporarily
      Purchase.skip_callback(:validation, :before, :set_purchase_date)
      purchase = build(:purchase, purchase_date: nil)
      expect(purchase).not_to be_valid
      expect(purchase.errors[:purchase_date]).to include("can't be blank")
      # Restore callback
      Purchase.set_callback(:validation, :before, :set_purchase_date)
    end
    
    it 'validates quantity is greater than 0' do
      purchase = build(:purchase, quantity: 0)
      expect(purchase).not_to be_valid
      expect(purchase.errors[:quantity]).to include('must be greater than 0')
    end
    
    it 'validates total_amount is greater than 0' do
      # Skip callbacks by using skip_callback temporarily
      Purchase.skip_callback(:validation, :before, :calculate_total_amount)
      purchase = build(:purchase, total_amount: 0)
      expect(purchase).not_to be_valid
      expect(purchase.errors[:total_amount]).to include('must be greater than 0')
      # Restore callback
      Purchase.set_callback(:validation, :before, :calculate_total_amount)
    end
  end

  describe 'scopes' do
    let!(:purchase1) { create(:purchase, purchase_date: 3.days.ago) }
    let!(:purchase2) { create(:purchase, purchase_date: 1.day.ago) }
    let!(:purchase3) { create(:purchase, purchase_date: Time.current) }

    describe '.ordered' do
      it 'returns purchases ordered by purchase_date desc' do
        expect(Purchase.ordered).to eq([purchase3, purchase2, purchase1])
      end
    end

    describe '.by_date_range' do
      it 'returns purchases within date range' do
        start_date = 2.days.ago.to_date
        end_date = Time.current.to_date
        result = Purchase.by_date_range(start_date, end_date)
        expect(result).to include(purchase2, purchase3)
        expect(result).not_to include(purchase1)
      end
    end

    describe '.by_customer' do
      let(:customer) { create(:customer) }
      let!(:customer_purchase) { create(:purchase, customer: customer) }

      it 'returns purchases for specific customer' do
        expect(Purchase.by_customer(customer.id)).to include(customer_purchase)
        expect(Purchase.by_customer(customer.id)).not_to include(purchase1, purchase2, purchase3)
      end
    end

    describe '.by_product' do
      let(:product) { create(:product) }
      let!(:product_purchase) { create(:purchase, product: product) }

      it 'returns purchases for specific product' do
        expect(Purchase.by_product(product.id)).to include(product_purchase)
        expect(Purchase.by_product(product.id)).not_to include(purchase1, purchase2, purchase3)
      end
    end

    describe '.by_category' do
      let(:category) { create(:category) }
      let(:product) { create(:product) }
      let!(:product_purchase) { create(:purchase, product: product) }

      before do
        product.categories << category
      end

      it 'returns purchases for products in specific category' do
        expect(Purchase.by_category(category.id)).to include(product_purchase)
        expect(Purchase.by_category(category.id)).not_to include(purchase1, purchase2, purchase3)
      end
    end

    describe '.today' do
      let!(:today_purchase) { create(:purchase, :today) }

      it 'returns purchases from today' do
        expect(Purchase.today).to include(today_purchase)
        expect(Purchase.today).not_to include(purchase1, purchase2)
      end
    end

    describe '.yesterday' do
      let!(:yesterday_purchase) { create(:purchase, :yesterday) }

      it 'returns purchases from yesterday' do
        expect(Purchase.yesterday).to include(yesterday_purchase)
        expect(Purchase.yesterday).not_to include(purchase1, purchase3)
      end
    end
  end

  describe 'callbacks' do
    describe 'before_validation' do
      describe '#set_purchase_date' do
        it 'sets purchase_date to current time if not present' do
          purchase = build(:purchase, purchase_date: nil)
          purchase.valid?
          expect(purchase.purchase_date).to be_present
          expect(purchase.purchase_date).to be_within(1.second).of(Time.current)
        end

        it 'does not override existing purchase_date' do
          original_date = 1.day.ago.change(usec: 0) # Remove microseconds for precision
          purchase = build(:purchase, purchase_date: original_date)
          purchase.valid?
          expect(purchase.purchase_date.change(usec: 0)).to eq(original_date)
        end
      end

      describe '#calculate_total_amount' do
        let(:product) { build_stubbed(:product, price: 25.0) }
        let(:purchase) { build(:purchase, product: product, quantity: 3, total_amount: nil) }

        it 'calculates total_amount based on product price and quantity' do
          purchase.valid?
          expect(purchase.total_amount).to eq(75.0)
        end

        it 'does not override existing total_amount' do
          purchase.total_amount = 100.0
          purchase.valid?
          expect(purchase.total_amount).to eq(100.0)
        end
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:purchase)).to be_valid
    end

    it 'creates purchase with today trait' do
      purchase = create(:purchase, :today)
      expect(purchase.purchase_date.to_date).to eq(Date.current)
    end

    it 'creates purchase with yesterday trait' do
      purchase = create(:purchase, :yesterday)
      expect(purchase.purchase_date.to_date).to eq(1.day.ago.to_date)
    end

    it 'creates purchase with high quantity trait' do
      purchase = create(:purchase, :high_quantity)
      expect(purchase.quantity).to be_between(10, 50)
    end
  end

  describe 'first purchase notification' do
    let(:admin_role) { create(:role, name: 'admin') }
    let(:product_creator) { create(:user, email: 'creator@example.com', role: admin_role) }
    let(:product) { create(:product, created_by: product_creator) }
    let(:customer) { create(:customer) }

    context 'when creating the first purchase for a product' do
      it 'sends first purchase notification' do
        expect(FirstPurchaseService).to receive(:new).and_call_original
        expect_any_instance_of(FirstPurchaseService).to receive(:notify_if_first_purchase)
        
        create(:purchase, product: product, customer: customer)
      end
    end

    context 'when creating subsequent purchases for a product' do
      before do
        create(:purchase, product: product, customer: customer)
      end

      it 'still calls the service but may not send notification' do
        expect(FirstPurchaseService).to receive(:new).and_call_original
        expect_any_instance_of(FirstPurchaseService).to receive(:notify_if_first_purchase)
        
        create(:purchase, product: product, customer: create(:customer))
      end
    end
  end
end
