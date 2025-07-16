require 'swagger_helper'

RSpec.describe 'Products API', type: :request, swagger_doc: 'v1/swagger.yaml' do
  let(:admin_user) { create(:user, role: 'admin') }
  let(:regular_user) { create(:user, role: 'user') }
  let(:category) { create(:category) }
  let(:product) { create(:product, category: category) }

  path '/api/v1/products' do
    get 'List products' do
      tags 'Products'
      produces 'application/json'
      security [bearerAuth: []]
      
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page'
      parameter name: :category_id, in: :query, type: :integer, required: false, description: 'Filter by category ID'
      parameter name: :search, in: :query, type: :string, required: false, description: 'Search by name or description'

      response '200', 'products list' do
        let(:Authorization) { "Bearer #{JWTService.encode(regular_user.id)}" }
        let!(:products) { create_list(:product, 3, category: category) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('products')
          expect(data).to have_key('meta')
          expect(data['products']).to be_an(Array)
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }

        run_test!
      end
    end

    post 'Create product' do
      tags 'Products'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: []]
      
      parameter name: :product_data, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: 'iPhone 15 Pro' },
          description: { type: :string, example: 'Latest iPhone model with advanced features' },
          price: { type: :string, example: '999.99' },
          stock: { type: :integer, example: 50 },
          category_ids: { 
            type: :array, 
            items: { type: :integer },
            example: [1, 2]
          },
          images: {
            type: :array,
            items: {
              type: :object,
              properties: {
                url: { type: :string, example: 'https://example.com/image.jpg' }
              }
            }
          }
        },
        required: %w[name description price stock]
      }

      response '201', 'product created' do
        let(:Authorization) { "Bearer #{JWTService.encode(admin_user.id)}" }
        let(:product_data) do
          {
            name: 'New Product',
            description: 'Product description',
            price: '99.99',
            stock: 100,
            category_ids: [category.id],
            images: [{ url: 'https://example.com/image.jpg' }]
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('product')
          expect(data['product']['name']).to eq('New Product')
        end
      end

      response '403', 'forbidden' do
        let(:Authorization) { "Bearer #{JWTService.encode(regular_user.id)}" }
        let(:product_data) { { name: 'Test Product', price: '99.99', stock: 10 } }

        run_test!
      end

      response '422', 'validation error' do
        let(:Authorization) { "Bearer #{JWTService.encode(admin_user.id)}" }
        let(:product_data) { { name: '', price: 'invalid', stock: -1 } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
        end
      end
    end
  end

  path '/api/v1/products/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'Get product' do
      tags 'Products'
      produces 'application/json'
      security [bearerAuth: []]

      response '200', 'product found' do
        let(:Authorization) { "Bearer #{JWTService.encode(regular_user.id)}" }
        let(:id) { product.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('product')
          expect(data['product']['id']).to eq(product.id)
        end
      end

      response '404', 'product not found' do
        let(:Authorization) { "Bearer #{JWTService.encode(regular_user.id)}" }
        let(:id) { 99999 }

        run_test!
      end
    end

    put 'Update product' do
      tags 'Products'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: []]
      
      parameter name: :product_data, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: 'Updated Product Name' },
          description: { type: :string, example: 'Updated description' },
          price: { type: :string, example: '89.99' },
          stock: { type: :integer, example: 75 }
        }
      }

      response '200', 'product updated' do
        let(:Authorization) { "Bearer #{JWTService.encode(admin_user.id)}" }
        let(:id) { product.id }
        let(:product_data) { { name: 'Updated Product', price: '89.99' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('product')
          expect(data['product']['name']).to eq('Updated Product')
        end
      end

      response '403', 'forbidden' do
        let(:Authorization) { "Bearer #{JWTService.encode(regular_user.id)}" }
        let(:id) { product.id }
        let(:product_data) { { name: 'Updated Product' } }

        run_test!
      end
    end

    delete 'Delete product' do
      tags 'Products'
      security [bearerAuth: []]

      response '204', 'product deleted' do
        let(:Authorization) { "Bearer #{JWTService.encode(admin_user.id)}" }
        let(:id) { product.id }

        run_test!
      end

      response '403', 'forbidden' do
        let(:Authorization) { "Bearer #{JWTService.encode(regular_user.id)}" }
        let(:id) { product.id }

        run_test!
      end
    end
  end
end
