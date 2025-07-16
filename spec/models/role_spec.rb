require 'rails_helper'

RSpec.describe Role, type: :model do
  describe "associations" do
    it "has many users" do
      expect(Role.reflect_on_association(:users).macro).to eq :has_many
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      role = build(:role)
      expect(role).to be_valid
    end

    it "is not valid without a name" do
      role = build(:role, name: nil)
      expect(role).not_to be_valid
      expect(role.errors[:name]).to include("can't be blank")
    end

    it "is not valid without a description" do
      role = build(:role, description: nil)
      expect(role).not_to be_valid
      expect(role.errors[:description]).to include("can't be blank")
    end

    it "enforces uniqueness of name" do
      create(:role, name: "test_role")
      duplicate_role = build(:role, name: "test_role")
      expect(duplicate_role).not_to be_valid
      expect(duplicate_role.errors[:name]).to include("has already been taken")
    end
  end

  describe "factory" do
    it "has a valid factory" do
      expect(build(:role)).to be_valid
    end

    it "has a valid admin factory" do
      expect(build(:role, :admin)).to be_valid
    end

    it "has a valid user factory" do
      expect(build(:role, :user)).to be_valid
    end
  end

  describe "integration with User" do
    it "can have multiple users" do
      role = create(:role)
      user1 = create(:user, role: role)
      user2 = create(:user, role: role)
      
      expect(role.users).to include(user1, user2)
      expect(role.users.count).to eq(2)
    end

    it "prevents deletion when it has associated users" do
      role = create(:role)
      create(:user, role: role)
      
      expect { role.destroy }.not_to change { Role.count }
    end
  end

  describe "name validation" do
    it "accepts valid role names" do
      valid_names = ["admin", "user", "moderator", "super_admin"]
      
      valid_names.each do |name|
        role = build(:role, name: name)
        expect(role).to be_valid
      end
    end

    it "rejects empty names" do
      role = build(:role, name: "")
      expect(role).not_to be_valid
      expect(role.errors[:name]).to include("can't be blank")
    end
  end
end
