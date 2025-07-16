require 'swagger_helper'

RSpec.describe 'Authentication API', type: :request, swagger_doc: 'v1/swagger.yaml' do
  path '/api/v1/auth/login' do
    post 'User login' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'admin@example.com' },
          password: { type: :string, example: 'password123' }
        },
        required: %w[email password]
      }

      response '200', 'login successful' do
        let(:user) { create(:user, email: 'admin@example.com', password: 'password123', role: 'admin') }
        let(:credentials) { { email: user.email, password: 'password123' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('token')
          expect(data).to have_key('user')
          expect(data['user']).to have_key('id')
          expect(data['user']).to have_key('email')
          expect(data['user']).to have_key('role')
        end
      end

      response '401', 'invalid credentials' do
        let(:credentials) { { email: 'invalid@example.com', password: 'wrongpassword' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('error')
        end
      end
    end
  end

  path '/api/v1/auth/register' do
    post 'User registration' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :user_data, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'user@example.com' },
          password: { type: :string, example: 'password123' },
          name: { type: :string, example: 'John Doe' }
        },
        required: %w[email password name]
      }

      response '201', 'user created' do
        let(:user_data) { { email: 'newuser@example.com', password: 'password123', name: 'New User' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('token')
          expect(data).to have_key('user')
          expect(data['user']['email']).to eq('newuser@example.com')
        end
      end

      response '422', 'validation error' do
        let(:user_data) { { email: 'invalid-email', password: '123', name: '' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
        end
      end
    end
  end
end
