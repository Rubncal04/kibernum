require 'swagger_helper'

RSpec.describe 'Purchases API', type: :request, swagger_doc: 'v1/swagger.yaml' do
  let(:admin_user) { create(:user, role: 'admin') }
  let(:regular_user) { create(:user, role: 'user') }
  let(:category) { create(:category) }
  let(:product1) { create(:product, category: category, price: '999.99', stock: 10) }
  let(:product2) { create(:product, category: category, price: '499.99', stock: 5) }

  path '/api/v1/purchases' do
    get 'List purchases' do
      tags 'Purchases'
      produces 'application/json'
      security [bearerAuth: []]
      
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page'

      response '200', 'purchases list' do
        let(:Authorization) { "Bearer #{JWTService.encode(admin_user.id)}" }
        let!(:purchase) { create(:purchase, customer: create(:customer)) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('purchases')
          expect(data).to have_key('meta')
          expect(data['purchases']).to be_an(Array)
        end
      end

      response '403', 'forbidden' do
        let(:Authorization) { "Bearer #{JWTService.encode(regular_user.id)}" }

        run_test!
      end
    end

    post 'Create purchase' do
      tags 'Purchases'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: []]
      
      parameter name: :purchase_data, in: :body, schema: {
        type: :object,
        properties: {
          customer: {
            type: :object,
            properties: {
              name: { type: :string, example: 'John Doe' },
              email: { type: :string, example: 'john@example.com' },
              phone: { type: :string, example: '+1234567890' }
            },
            required: %w[name email]
          },
          items: {
            type: :array,
            items: {
              type: :object,
              properties: {
                product_id: { type: :integer, example: 1 },
                quantity: { type: :integer, example: 2 }
              },
              required: %w[product_id quantity]
            }
          }
        },
        required: %w[customer items]
      }

      response '201', 'purchase created' do
        let(:Authorization) { "Bearer #{JWTService.encode(regular_user.id)}" }
        let(:purchase_data) do
          {
            customer: {
              name: 'John Doe',
              email: 'john@example.com',
              phone: '+1234567890'
            },
            items: [
              {
                product_id: product1.id,
                quantity: 2
              },
              {
                product_id: product2.id,
                quantity: 1
              }
            ]
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('purchase')
          expect(data['purchase']).to have_key('id')
          expect(data['purchase']).to have_key('total_amount')
          expect(data['purchase']).to have_key('customer')
          expect(data['purchase']).to have_key('items')
        end
      end

      response '422', 'validation error' do
        let(:Authorization) { "Bearer #{JWTService.encode(regular_user.id)}" }
        let(:purchase_data) do
          {
            customer: {
              name: '',
              email: 'invalid-email'
            },
            items: [
              {
                product_id: 99999,
                quantity: 0
              }
            ]
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
        end
      end

      response '422', 'insufficient stock' do
        let(:Authorization) { "Bearer #{JWTService.encode(regular_user.id)}" }
        let(:purchase_data) do
          {
            customer: {
              name: 'John Doe',
              email: 'john@example.com'
            },
            items: [
              {
                product_id: product1.id,
                quantity: 999
              }
            ]
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
        end
      end
    end
  end

  path '/api/v1/purchases/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'Get purchase' do
      tags 'Purchases'
      produces 'application/json'
      security [bearerAuth: []]

      response '200', 'purchase found' do
        let(:Authorization) { "Bearer #{JWTService.encode(admin_user.id)}" }
        let(:purchase) { create(:purchase, customer: create(:customer)) }
        let(:id) { purchase.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('purchase')
          expect(data['purchase']['id']).to eq(purchase.id)
        end
      end

      response '404', 'purchase not found' do
        let(:Authorization) { "Bearer #{JWTService.encode(admin_user.id)}" }
        let(:id) { 99999 }

        run_test!
      end
    end
  end
end
