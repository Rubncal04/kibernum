require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'associations' do
    it 'has many purchases' do
      expect(Customer.reflect_on_association(:purchases).macro).to eq :has_many
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      customer = build(:customer)
      expect(customer).to be_valid
    end

    it 'is not valid without a name' do
      customer = build(:customer, name: nil)
      expect(customer).not_to be_valid
      expect(customer.errors[:name]).to include("can't be blank")
    end

    it 'is not valid without an email' do
      customer = build(:customer, email: nil)
      expect(customer).not_to be_valid
      expect(customer.errors[:email]).to include("can't be blank")
    end

    it 'is not valid with duplicate email' do
      create(:customer, email: 'test@example.com')
      customer = build(:customer, email: 'test@example.com')
      expect(customer).not_to be_valid
      expect(customer.errors[:email]).to include('has already been taken')
    end
    
    it 'validates email format' do
      customer = build(:customer, email: 'invalid-email')
      expect(customer).not_to be_valid
      expect(customer.errors[:email]).to include('is invalid')
    end
    
    it 'validates name length' do
      customer = build(:customer, name: 'A')
      expect(customer).not_to be_valid
      expect(customer.errors[:name]).to include('is too short (minimum is 2 characters)')
    end
    
    it 'validates phone length' do
      customer = build(:customer, phone: 'A' * 21)
      expect(customer).not_to be_valid
      expect(customer.errors[:phone]).to include('is too long (maximum is 20 characters)')
    end
    
    it 'validates address length' do
      customer = build(:customer, address: 'A' * 501)
      expect(customer).not_to be_valid
      expect(customer.errors[:address]).to include('is too long (maximum is 500 characters)')
    end
  end

  describe 'scopes' do
    let!(:customer1) { create(:customer, name: 'Alice') }
    let!(:customer2) { create(:customer, name: 'Bob') }
    let!(:customer3) { create(:customer, name: 'Charlie') }

    describe '.ordered' do
      it 'returns customers ordered by name' do
        expect(Customer.ordered).to eq([customer1, customer2, customer3])
      end
    end

    describe '.with_purchases' do
      let!(:purchase) { create(:purchase, customer: customer1) }

      it 'returns only customers with purchases' do
        expect(Customer.with_purchases).to include(customer1)
        expect(Customer.with_purchases).not_to include(customer2, customer3)
      end
    end

    describe '.by_email' do
      it 'returns customer by email' do
        expect(Customer.by_email(customer1.email)).to eq([customer1])
      end
    end
  end

  describe 'instance methods' do
    let(:customer) { build_stubbed(:customer) }
    let(:purchase1) { build_stubbed(:purchase, customer: customer, quantity: 2, total_amount: 100.0, purchase_date: 1.day.ago) }
    let(:purchase2) { build_stubbed(:purchase, customer: customer, quantity: 1, total_amount: 50.0, purchase_date: Time.current) }

    before do
      allow(customer).to receive(:purchases).and_return([purchase1, purchase2])
    end

    describe '#total_purchases' do
      it 'returns total number of purchases' do
        expect(customer.total_purchases).to eq(2)
      end
    end

    describe '#total_spent' do
      it 'returns total amount spent' do
        expect(customer.total_spent).to eq(150.0)
      end
    end

    describe '#last_purchase_date' do
      it 'returns the most recent purchase date' do
        expect(customer.last_purchase_date).to eq(purchase2.purchase_date)
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:customer)).to be_valid
    end

    it 'has a valid minimal factory' do
      expect(build(:customer, :minimal)).to be_valid
    end

    it 'can be associated with purchases' do
      customer = build_stubbed(:customer)
      purchase = build_stubbed(:purchase, customer: customer)
      
      allow(customer).to receive(:purchases).and_return([purchase])
      expect(customer.purchases).to include(purchase)
    end
  end
end
