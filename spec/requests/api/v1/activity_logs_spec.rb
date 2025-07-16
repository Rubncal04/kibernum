require 'swagger_helper'

RSpec.describe 'Activity Logs API', type: :request, swagger_doc: 'v1/swagger.yaml' do
  let(:admin_user) { create(:user, role: 'admin') }
  let(:regular_user) { create(:user, role: 'user') }
  let(:category) { create(:category) }
  let(:product) { create(:product, category: category) }

  path '/api/v1/activity_logs' do
    get 'List activity logs' do
      tags 'Activity Logs'
      produces 'application/json'
      security [bearerAuth: []]
      
      parameter name: :user_id, in: :query, type: :integer, required: false, description: 'Filter by user ID'
      parameter name: :scope_type, in: :query, type: :string, required: false, description: 'Filter by scope type (Product, Category)'
      parameter name: :scope_id, in: :query, type: :integer, required: false, description: 'Filter by scope ID'
      parameter name: :action, in: :query, type: :string, required: false, description: 'Filter by action (create, update, destroy)'
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page'

      response '200', 'activity logs list' do
        let(:Authorization) { "Bearer #{JWTService.encode(admin_user.id)}" }
        let!(:activity_log) { create(:activity_log, scope: product, user: admin_user, action: 'create') }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('activity_logs')
          expect(data).to have_key('meta')
          expect(data['activity_logs']).to be_an(Array)
        end
      end

      response '403', 'forbidden' do
        let(:Authorization) { "Bearer #{JWTService.encode(regular_user.id)}" }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end
  end

  path '/api/v1/activity_logs/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'Get activity log' do
      tags 'Activity Logs'
      produces 'application/json'
      security [bearerAuth: []]

      response '200', 'activity log found' do
        let(:Authorization) { "Bearer #{JWTService.encode(admin_user.id)}" }
        let(:activity_log) { create(:activity_log, scope: product, user: admin_user) }
        let(:id) { activity_log.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('activity_log')
          expect(data['activity_log']['id']).to eq(activity_log.id)
          expect(data['activity_log']).to have_key('action')
          expect(data['activity_log']).to have_key('scope_type')
          expect(data['activity_log']).to have_key('user_name')
        end
      end

      response '404', 'activity log not found' do
        let(:Authorization) { "Bearer #{JWTService.encode(admin_user.id)}" }
        let(:id) { 99999 }

        run_test!
      end

      response '403', 'forbidden' do
        let(:Authorization) { "Bearer #{JWTService.encode(regular_user.id)}" }
        let(:activity_log) { create(:activity_log, scope: product, user: admin_user) }
        let(:id) { activity_log.id }

        run_test!
      end
    end
  end
end
