require 'rails_helper'

RSpec.describe User, type: :model do
  describe "devise modules" do
    it "includes the expected devise modules" do
      expect(User.devise_modules).to include(:database_authenticatable)
      expect(User.devise_modules).to include(:registerable)
      expect(User.devise_modules).to include(:recoverable)
      expect(User.devise_modules).to include(:rememberable)
      expect(User.devise_modules).to include(:validatable)
    end
  end

  describe "associations" do
    it "belongs to a role" do
      expect(User.reflect_on_association(:role).macro).to eq :belongs_to
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      user = build(:user)
      expect(user).to be_valid
    end

    it "is not valid without a name" do
      user = build(:user, name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it "is not valid without an email" do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "enforces uniqueness of email" do
      create(:user, email: "test@example.com")
      duplicate_user = build(:user, email: "test@example.com")
      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:email]).to include("has already been taken")
    end
  end

  describe "factory" do
    it "has a valid factory" do
      expect(build(:user)).to be_valid
    end

    it "has a valid admin factory" do
      expect(build(:user, :admin)).to be_valid
    end

    it "has a valid regular user factory" do
      expect(build(:user, :regular_user)).to be_valid
    end
  end

  describe "role methods" do
    let(:admin_role) { create(:role, :admin) }
    let(:user_role) { create(:role, :user) }
    let(:admin_user) { create(:user, role: admin_role) }
    let(:regular_user) { create(:user, role: user_role) }

    describe "#admin?" do
      it "returns true for admin users" do
        expect(admin_user.admin?).to be true
      end

      it "returns false for regular users" do
        expect(regular_user.admin?).to be false
      end
    end

    describe "#regular_user?" do
      it "returns true for regular users" do
        expect(regular_user.regular_user?).to be true
      end

      it "returns false for admin users" do
        expect(admin_user.regular_user?).to be false
      end
    end
  end

  describe "integration with Role" do
    let(:admin_role) { create(:role, :admin) }
    let(:user_role) { create(:role, :user) }

    it "can be associated with different roles" do
      admin_user = create(:user, role: admin_role)
      regular_user = create(:user, role: user_role)
      
      expect(admin_user.role).to eq(admin_role)
      expect(regular_user.role).to eq(user_role)
    end

    it "cannot exist without a role" do
      user_without_role = build(:user, role: nil)
      expect(user_without_role).not_to be_valid
    end
  end

  describe "devise authentication" do
    it "can be authenticated with valid credentials" do
      user = create(:user, email: "test@example.com", password: "password123")
      expect(user.valid_password?("password123")).to be true
    end

    it "cannot be authenticated with invalid credentials" do
      user = create(:user, email: "test@example.com", password: "password123")
      expect(user.valid_password?("wrongpassword")).to be false
    end
  end
end
