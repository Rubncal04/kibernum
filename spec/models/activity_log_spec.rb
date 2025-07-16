require 'rails_helper'

RSpec.describe ActivityLog, type: :model do
  let(:admin_user) { create(:user, :admin) }
  let(:product) { create(:product, created_by: admin_user) }
  let(:category) { create(:category, created_by: admin_user) }

  describe 'associations' do
    it 'belongs to a scope (polymorphic)' do
      expect(ActivityLog.reflect_on_association(:scope).macro).to eq :belongs_to
    end

    it 'belongs to a user' do
      expect(ActivityLog.reflect_on_association(:user).macro).to eq :belongs_to
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      activity_log = build(:activity_log, scope: product, user: admin_user)
      expect(activity_log).to be_valid
    end

    it 'is not valid without action' do
      activity_log = build(:activity_log, action: nil)
      expect(activity_log).not_to be_valid
      expect(activity_log.errors[:action]).to include("can't be blank")
    end

    it 'is not valid with invalid action' do
      activity_log = build(:activity_log, action: 'invalid_action')
      expect(activity_log).not_to be_valid
      expect(activity_log.errors[:action]).to include('is not included in the list')
    end

    it 'is not valid without changes_data' do
      activity_log = build(:activity_log, changes_data: nil)
      expect(activity_log).not_to be_valid
      expect(activity_log.errors[:changes_data]).to include("can't be blank")
    end

    it 'is not valid without scope_type' do
      activity_log = build(:activity_log, scope_type: nil)
      expect(activity_log).not_to be_valid
      expect(activity_log.errors[:scope_type]).to include("can't be blank")
    end

    it 'is not valid without scope_id' do
      activity_log = build(:activity_log, scope_id: nil)
      expect(activity_log).not_to be_valid
      expect(activity_log.errors[:scope_id]).to include("can't be blank")
    end
  end

  describe 'scopes' do
    let!(:product_log) { create(:activity_log, :for_product, scope: product, user: admin_user) }
    let!(:category_log) { create(:activity_log, :for_category, scope: category, user: admin_user) }
    let!(:create_log) { create(:activity_log, :create_action, scope: product, user: admin_user) }
    let!(:update_log) { create(:activity_log, :update_action, scope: product, user: admin_user) }

    describe '.by_user' do
      it 'filters by user' do
        expect(ActivityLog.by_user(admin_user.id)).to include(product_log, category_log)
      end
    end

    describe '.by_scope_type' do
      it 'filters by scope type' do
        expect(ActivityLog.by_scope_type('Product')).to include(product_log)
        expect(ActivityLog.by_scope_type('Product')).not_to include(category_log)
      end
    end

    describe '.by_action' do
      it 'filters by action' do
        expect(ActivityLog.by_action('create')).to include(create_log)
        expect(ActivityLog.by_action('update')).to include(update_log)
      end
    end

    describe '.recent' do
      it 'orders by created_at desc' do
        expect(ActivityLog.recent.first).to eq(update_log)
      end
    end

    describe '.for_product' do
      it 'filters for products only' do
        expect(ActivityLog.for_product).to include(product_log)
        expect(ActivityLog.for_product).not_to include(category_log)
      end
    end

    describe '.for_category' do
      it 'filters for categories only' do
        expect(ActivityLog.for_category).to include(category_log)
        expect(ActivityLog.for_category).not_to include(product_log)
      end
    end
  end

  describe 'class methods' do
    describe '.log_activity' do
      it 'creates an activity log' do
        expect {
          ActivityLog.log_activity(product, admin_user, 'create', { 'after' => { 'name' => 'Test' } })
        }.to change(ActivityLog, :count).by(1)
      end

      it 'sets the correct attributes' do
        log = ActivityLog.log_activity(product, admin_user, 'update', { 'before' => {}, 'after' => {} })
        
        expect(log.scope).to eq(product)
        expect(log.user).to eq(admin_user)
        expect(log.action).to eq('update')
        expect(log.changes_data).to eq({ 'before' => {}, 'after' => {} })
      end
    end
  end

  describe 'instance methods' do
    let(:activity_log) { create(:activity_log, scope: product, user: admin_user) }

    describe '#scope_name' do
      it 'returns the scope name' do
        expect(activity_log.scope_name).to eq(product.name)
      end
    end

    describe '#user_name' do
      it 'returns the user name' do
        expect(activity_log.user_name).to eq(admin_user.name)
      end

      it 'returns unknown when user is nil' do
        activity_log.user = nil
        expect(activity_log.user_name).to eq('Unknown User')
      end
    end

    describe '#formatted_changes' do
      context 'for create action' do
        let(:activity_log) { create(:activity_log, :create_action, scope: product, user: admin_user) }

        it 'returns formatted create message' do
          expect(activity_log.formatted_changes).to include('Created product')
          expect(activity_log.formatted_changes).to include(product.name)
        end
      end

      context 'for update action' do
        let(:activity_log) { create(:activity_log, :update_action, scope: product, user: admin_user) }

        it 'returns formatted update message' do
          expect(activity_log.formatted_changes).to include('Updated product')
          expect(activity_log.formatted_changes).to include(product.name)
          expect(activity_log.formatted_changes).to include('Name')
        end
      end

      context 'for destroy action' do
        let(:activity_log) { create(:activity_log, :destroy_action, scope: product, user: admin_user) }

        it 'returns formatted destroy message' do
          expect(activity_log.formatted_changes).to include('Deleted product')
          expect(activity_log.formatted_changes).to include(product.name)
        end
      end
    end

    describe '#changes_summary' do
      context 'for create action' do
        let(:activity_log) { create(:activity_log, :create_action, scope: product, user: admin_user) }

        it 'returns created data' do
          expect(activity_log.changes_summary).to have_key('created')
        end
      end

      context 'for update action' do
        let(:activity_log) { create(:activity_log, :update_action, scope: product, user: admin_user) }

        it 'returns before and after data' do
          summary = activity_log.changes_summary
          expect(summary).to have_key('before')
          expect(summary).to have_key('after')
        end
      end

      context 'for destroy action' do
        let(:activity_log) { create(:activity_log, :destroy_action, scope: product, user: admin_user) }

        it 'returns destroyed data' do
          expect(activity_log.changes_summary).to have_key('destroyed')
        end
      end
    end
  end
end
