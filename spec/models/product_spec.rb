require 'rails_helper'

RSpec.describe Product, type: :model do
  describe "associations" do
    it "belongs to a creator user" do
      expect(Product.reflect_on_association(:created_by).macro).to eq :belongs_to
    end

    it "has and belongs to many categories" do
      expect(Product.reflect_on_association(:categories).macro).to eq :has_and_belongs_to_many
    end

    it "has many purchases" do
      expect(Product.reflect_on_association(:purchases).macro).to eq :has_many
    end

    it "has many product_images" do
      expect(Product.reflect_on_association(:product_images).macro).to eq :has_many
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      product = build(:product)
      expect(product).to be_valid
    end

    it "is not valid without a name" do
      product = build(:product, name: nil)
      expect(product).not_to be_valid
      expect(product.errors[:name]).to include("can't be blank")
    end

    it "is not valid without a description" do
      product = build(:product, description: nil)
      expect(product).not_to be_valid
      expect(product.errors[:description]).to include("can't be blank")
    end

    it "is not valid without a price" do
      product = build(:product, price: nil)
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include("can't be blank")
    end

    it "is not valid with a negative price" do
      product = build(:product, price: -10)
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include("must be greater than 0")
    end

    it "is not valid without stock" do
      product = build(:product, stock: nil)
      expect(product).not_to be_valid
      expect(product.errors[:stock]).to include("can't be blank")
    end

    it "is not valid with negative stock" do
      product = build(:product, stock: -5)
      expect(product).not_to be_valid
      expect(product.errors[:stock]).to include("must be greater than or equal to 0")
    end

    it "is valid with zero stock" do
      product = build(:product, stock: 0)
      expect(product).to be_valid
    end
  end

  describe "scopes" do
    let!(:product1) { create(:product, name: "Apple") }
    let!(:product2) { create(:product, name: "Banana") }
    let!(:product3) { create(:product, name: "Cherry") }

    describe ".ordered" do
      it "returns products ordered by name" do
        expect(Product.ordered).to eq([product1, product2, product3])
      end
    end

    describe ".in_stock" do
      let!(:out_of_stock_product) { create(:product, :out_of_stock) }

      it "returns only products with stock greater than 0" do
        expect(Product.in_stock).to include(product1, product2, product3)
        expect(Product.in_stock).not_to include(out_of_stock_product)
      end
    end

    describe ".by_category" do
      let(:category) { create(:category) }
      let!(:categorized_product) { create(:product) }

      before do
        categorized_product.categories << category
      end

      it "returns products in specific category" do
        expect(Product.by_category(category.id)).to include(categorized_product)
        expect(Product.by_category(category.id)).not_to include(product1, product2, product3)
      end
    end

    describe ".with_purchases" do
      let!(:purchase) { create(:purchase, product: product1) }

      it "returns only products with purchases" do
        expect(Product.with_purchases).to include(product1)
        expect(Product.with_purchases).not_to include(product2, product3)
      end
    end

    describe ".most_purchased" do
      let!(:purchase1) { create(:purchase, product: product1, quantity: 5) }
      let!(:purchase2) { create(:purchase, product: product2, quantity: 10) }
      let!(:purchase3) { create(:purchase, product: product1, quantity: 3) }

      it "returns products ordered by total purchase quantity" do
        result = Product.most_purchased
        expect(result.first).to eq(product2)  # product2 has 10 units
        expect(result.second).to eq(product1) # product1 has 5+3=8 units
      end
    end

    describe ".top_revenue" do
      let!(:purchase1) { create(:purchase, product: product1, total_amount: 100.0) }
      let!(:purchase2) { create(:purchase, product: product2, total_amount: 200.0) }
      let!(:purchase3) { create(:purchase, product: product1, total_amount: 50.0) }

      it "returns products ordered by total revenue" do
        result = Product.top_revenue
        expect(result.first).to eq(product2)
        expect(result.second).to eq(product1)
      end
    end
  end

  describe "factory" do
    it "has a valid factory" do
      expect(build(:product)).to be_valid
    end

    it "has a valid out_of_stock factory" do
      expect(build(:product, :out_of_stock)).to be_valid
    end

    it "has a valid low_stock factory" do
      expect(build(:product, :low_stock)).to be_valid
    end

    it "has a valid expensive factory" do
      expect(build(:product, :expensive)).to be_valid
    end

    it "has a valid cheap factory" do
      expect(build(:product, :cheap)).to be_valid
    end
  end

  describe "instance methods" do
    describe "#available?" do
      it "returns true when stock is greater than 0" do
        product = build(:product, stock: 5)
        expect(product.available?).to be true
      end

      it "returns false when stock is 0" do
        product = build(:product, stock: 0)
        expect(product.available?).to be false
      end
    end

    describe "#low_stock?" do
      it "returns true when stock is 5 or less" do
        product = build(:product, stock: 5)
        expect(product.low_stock?).to be true
      end

      it "returns false when stock is greater than 5" do
        product = build(:product, stock: 6)
        expect(product.low_stock?).to be false
      end
    end

    describe "#total_purchases" do
      let(:product) { create(:product) }
      let!(:purchase1) { create(:purchase, product: product, quantity: 3) }
      let!(:purchase2) { create(:purchase, product: product, quantity: 2) }

      it "returns total quantity of purchases" do
        expect(product.total_purchases).to eq(5)
      end
    end

    describe "#total_revenue" do
      let(:product) { create(:product) }
      let!(:purchase1) { create(:purchase, product: product, total_amount: 100.0) }
      let!(:purchase2) { create(:purchase, product: product, total_amount: 50.0) }

      it "returns total revenue from purchases" do
        expect(product.total_revenue).to eq(150.0)
      end
    end

    describe "#primary_image" do
      let(:product) { create(:product) }
      let!(:secondary_image) { create(:product_image, product: product, is_primary: false) }
      let!(:primary_image) { create(:product_image, product: product, is_primary: true) }

      it "returns the primary image" do
        expect(product.primary_image).to eq(primary_image)
      end
    end

    describe "#first_purchase_date" do
      let(:product) { create(:product) }
      let!(:purchase1) { create(:purchase, product: product, purchase_date: 2.days.ago) }
      let!(:purchase2) { create(:purchase, product: product, purchase_date: 1.day.ago) }

      it "returns the earliest purchase date" do
        expect(product.first_purchase_date).to eq(purchase1.purchase_date)
      end
    end
  end

  describe "integration with Category" do
    let(:category) { build(:category) }
    let(:product) { build(:product) }

    it "can be associated with a category" do
      product.categories << category
      expect(product.categories).to include(category)
    end
  end

  describe "integration with User" do
    let(:admin_user) { build(:user, :admin) }
    let(:product) { build(:product, created_by: admin_user) }

    it "belongs to the user who created it" do
      expect(product.created_by).to eq(admin_user)
    end
  end

  describe "integration with Purchase" do
    let(:product) { create(:product) }
    let(:customer) { create(:customer) }
    let!(:purchase) { create(:purchase, product: product, customer: customer) }

    it "has purchases" do
      expect(product.purchases).to include(purchase)
    end
  end

  describe "integration with ProductImage" do
    let(:product) { create(:product) }
    let!(:product_image) { create(:product_image, product: product) }

    it "has product images" do
      expect(product.product_images).to include(product_image)
    end
  end
end
