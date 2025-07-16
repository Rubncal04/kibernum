module Api
  module V1
    class CustomersController < BaseController
      include CacheInvalidation
      before_action :set_customer, only: [:show, :update, :destroy]

      def index
        page = params[:page] || 1
        per_page = params[:per_page] || 20
        
        cache_key = "customers_index:#{page}:#{per_page}:#{Customer.maximum(:updated_at)&.to_i}"

        result = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
          @customers = Customer.includes(:purchases)
                              .ordered
                              .page(page)
                              .per(per_page)

          {
            customers: @customers.map { |customer| customer_response(customer) },
            pagination: {
              current_page: @customers.current_page,
              total_pages: @customers.total_pages,
              total_count: @customers.total_count
            }
          }
        end

        render json: {
          status: 'success',
          data: result,
          cached: true
        }
      end

      def show
        render json: {
          status: 'success',
          data: {
            customer: customer_response(@customer)
          }
        }
      end

      def create
        @customer = Customer.new(customer_params)

        if @customer.save
          invalidate_customer_cache
          render json: {
            status: 'success',
            message: 'Customer created successfully',
            data: {
              customer: customer_response(@customer)
            }
          }, status: :created
        else
          render json: {
            status: 'error',
            message: 'Customer creation failed',
            errors: @customer.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        if @customer.update(customer_params)
          invalidate_customer_cache
          render json: {
            status: 'success',
            message: 'Customer updated successfully',
            data: {
              customer: customer_response(@customer)
            }
          }
        else
          render json: {
            status: 'error',
            message: 'Customer update failed',
            errors: @customer.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        if @customer.destroy
          invalidate_customer_cache
          render json: {
            status: 'success',
            message: 'Customer deleted successfully'
          }
        else
          render json: {
            status: 'error',
            message: 'Customer deletion failed',
            errors: @customer.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def set_customer
        @customer = Customer.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {
          status: 'error',
          message: 'Customer not found'
        }, status: :not_found
        return false
      end

      def customer_params
        params.require(:customer).permit(:name, :email, :phone, :address)
      end

      def customer_response(customer)
        {
          id: customer.id,
          name: customer.name,
          email: customer.email,
          phone: customer.phone,
          address: customer.address,
          total_purchases: customer.total_purchases,
          total_spent: customer.total_spent,
          last_purchase_date: customer.last_purchase_date,
          created_at: customer.created_at,
          updated_at: customer.updated_at
        }
      end
    end
  end
end
