require 'rails_helper'

RSpec.describe ProductImage, type: :model do
  describe "associations" do
    it "belongs to product" do
      expect(ProductImage.reflect_on_association(:product).macro).to eq :belongs_to
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      product_image = build(:product_image)
      expect(product_image).to be_valid
    end

    it "is not valid without image_url" do
      product_image = build(:product_image, image_url: nil)
      expect(product_image).not_to be_valid
      expect(product_image.errors[:image_url]).to include("can't be blank")
    end

    it "is not valid without order_index" do
      product_image = build(:product_image, order_index: nil)
      expect(product_image).not_to be_valid
      expect(product_image.errors[:order_index]).to include("can't be blank")
    end

    it "is not valid without is_primary" do
      product_image = build(:product_image, is_primary: nil)
      expect(product_image).not_to be_valid
      expect(product_image.errors[:is_primary]).to include("is not included in the list")
    end
    
    it "validates order_index is greater than or equal to 0" do
      product_image = build(:product_image, order_index: -1)
      expect(product_image).not_to be_valid
      expect(product_image.errors[:order_index]).to include("must be greater than or equal to 0")
    end
  end

  describe "scopes" do
    let(:product) { create(:product) }
    let!(:image1) { create(:product_image, product: product, order_index: 2) }
    let!(:image2) { create(:product_image, product: product, order_index: 0) }
    let!(:image3) { create(:product_image, product: product, order_index: 1) }

    describe ".ordered" do
      it "returns images ordered by order_index" do
        expect(ProductImage.ordered).to eq([image2, image3, image1])
      end
    end

    describe ".primary" do
      let!(:primary_image) { create(:product_image, product: product, is_primary: true) }

      it "returns only primary images" do
        expect(ProductImage.primary).to include(primary_image)
        expect(ProductImage.primary).not_to include(image1, image2, image3)
      end
    end

    describe ".by_product" do
      let(:other_product) { create(:product) }
      let!(:other_image) { create(:product_image, product: other_product) }

      it "returns images for specific product" do
        expect(ProductImage.by_product(product.id)).to include(image1, image2, image3)
        expect(ProductImage.by_product(product.id)).not_to include(other_image)
      end
    end
  end

  describe "callbacks" do
    describe "before_save" do
      describe "#ensure_single_primary_per_product" do
        let(:product) { create(:product) }
        let!(:existing_primary) { create(:product_image, product: product, is_primary: true) }
        let!(:existing_secondary) { create(:product_image, product: product, is_primary: false) }

        it "sets other images to non-primary when setting one as primary" do
          new_primary = create(:product_image, product: product, is_primary: true)
          
          existing_primary.reload
          existing_secondary.reload
          
          expect(existing_primary.is_primary).to be false
          expect(existing_secondary.is_primary).to be false
          expect(new_primary.is_primary).to be true
        end

        it "does not affect images from other products" do
          other_product = create(:product)
          other_primary = create(:product_image, product: other_product, is_primary: true)
          
          new_primary = create(:product_image, product: product, is_primary: true)
          
          other_primary.reload
          expect(other_primary.is_primary).to be true
        end
      end
    end
  end

  describe "factory" do
    it "has a valid factory" do
      expect(build(:product_image)).to be_valid
    end

    it "creates primary image with primary trait" do
      product_image = create(:product_image, :primary)
      expect(product_image.is_primary).to be true
      expect(product_image.order_index).to eq(0)
    end

    it "creates image with alt text trait" do
      product_image = create(:product_image, :with_alt_text)
      expect(product_image.alt_text).to be_present
    end

    it "creates first image with first trait" do
      product_image = create(:product_image, :first)
      expect(product_image.order_index).to eq(0)
    end

    it "creates last image with last trait" do
      product_image = create(:product_image, :last)
      expect(product_image.order_index).to eq(10)
    end
  end
end
