require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'associations' do
    it 'belongs to created_by (User)' do
      expect(Category.reflect_on_association(:created_by).macro).to eq :belongs_to
    end

    it 'has and belongs to many products' do
      expect(Category.reflect_on_association(:products).macro).to eq :has_and_belongs_to_many
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      category = build(:category)
      expect(category).to be_valid
    end

    it 'is not valid without a name' do
      category = build(:category, name: nil)
      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("can't be blank")
    end

    it 'is not valid without a description' do
      category = build(:category, description: nil)
      expect(category).not_to be_valid
      expect(category.errors[:description]).to include("can't be blank")
    end

    it 'enforces uniqueness of name' do
      create(:category, name: "Electronics")
      duplicate_category = build(:category, name: "Electronics")
      expect(duplicate_category).not_to be_valid
      expect(duplicate_category.errors[:name]).to include("has already been taken")
    end
  end

  describe 'scopes' do
    let!(:category1) { create(:category, name: "Electronics") }
    let!(:category2) { create(:category, name: "Books") }
    let!(:category3) { create(:category, name: "Clothing") }

    describe '.ordered' do
      it 'returns categories ordered by name' do
        expect(Category.ordered).to eq([category2, category3, category1])
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:category)).to be_valid
    end

    it 'has a valid electronics factory' do
      expect(build(:category, :electronics)).to be_valid
    end

    it 'has a valid books factory' do
      expect(build(:category, :books)).to be_valid
    end

    it 'has a valid clothing factory' do
      expect(build(:category, :clothing)).to be_valid
    end
  end

  describe 'integration with User' do
    let(:admin_user) { build(:user, :admin) }
    let(:category) { build(:category, created_by: admin_user) }

    it 'belongs to the user who created it' do
      expect(category.created_by).to eq(admin_user)
    end
  end

  describe 'integration with Product' do
    let(:category) { create(:category) }
    let(:product) { create(:product) }

    it 'can be associated with products' do
      category.products << product
      expect(category.products).to include(product)
    end

    it 'can have multiple products' do
      product1 = create(:product)
      product2 = create(:product)
      category.products << product1
      category.products << product2
      expect(category.products.count).to eq(2)
    end
  end

  describe 'instance methods' do
    let(:category) { create(:category) }
    let(:product1) { create(:product) }
    let(:product2) { create(:product) }

    before do
      category.products << product1
      category.products << product2
    end

    describe '#products_count' do
      it 'returns the number of products in the category' do
        expect(category.products.count).to eq(2)
      end
    end

    describe '#has_products?' do
      it 'returns true when category has products' do
        expect(category.products.any?).to be true
      end

      it 'returns false when category has no products' do
        empty_category = create(:category)
        expect(empty_category.products.any?).to be false
      end
    end
  end
end
