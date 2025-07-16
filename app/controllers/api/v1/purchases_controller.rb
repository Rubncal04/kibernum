module Api
  module V1
    class PurchasesController < BaseController
      before_action :set_purchase, only: [:show, :update, :destroy]

      def index
        @purchases = apply_filters(Purchase.includes(:customer, :product, product: :categories))
                              .ordered
                              .page(params[:page])
                              .per(params[:per_page] || 20)

        render json: {
          status: 'success',
          data: {
            purchases: @purchases.map { |purchase| purchase_response(purchase) },
            pagination: {
              current_page: @purchases.current_page,
              total_pages: @purchases.total_pages,
              total_count: @purchases.total_count
            }
          }
        }
      end

      def show
        render json: {
          status: 'success',
          data: {
            purchase: purchase_response(@purchase)
          }
        }
      end

      def create
        @purchase = Purchase.new(purchase_params)

        if @purchase.save
          render json: {
            status: 'success',
            message: 'Purchase created successfully',
            data: {
              purchase: purchase_response(@purchase)
            }
          }, status: :created
        else
          render json: {
            status: 'error',
            message: 'Purchase creation failed',
            errors: @purchase.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        if @purchase.update(purchase_params)
          render json: {
            status: 'success',
            message: 'Purchase updated successfully',
            data: {
              purchase: purchase_response(@purchase)
            }
          }
        else
          render json: {
            status: 'error',
            message: 'Purchase update failed',
            errors: @purchase.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        if @purchase.destroy
          render json: {
            status: 'success',
            message: 'Purchase deleted successfully'
          }
        else
          render json: {
            status: 'error',
            message: 'Purchase deletion failed',
            errors: @purchase.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def filtered_list
        purchases = apply_filters(Purchase.includes(:customer, :product, product: :categories))
                              .ordered

        render json: {
          status: 'success',
          data: {
            purchases: purchases.map { |purchase| purchase_response(purchase) },
            total_count: purchases.count,
            filters_applied: {
              date_from: params[:date_from],
              date_to: params[:date_to],
              category_id: params[:category_id],
              customer_id: params[:customer_id],
              admin_id: params[:admin_id]
            }
          }
        }
      end

      def purchases_by_granularity
        granularity = params[:granularity]&.downcase
        unless %w[hour day week year].include?(granularity)
          render json: {
            status: 'error',
            message: 'Invalid granularity. Must be: hour, day, week, year'
          }, status: :bad_request
          return
        end

        purchases = apply_filters(Purchase.all)
        result = aggregate_purchases_by_granularity(purchases, granularity)

        render json: {
          status: 'success',
          data: {
            granularity: granularity,
            purchases_count: result,
            filters_applied: {
              date_from: params[:date_from],
              date_to: params[:date_to],
              category_id: params[:category_id],
              customer_id: params[:customer_id],
              admin_id: params[:admin_id]
            }
          }
        }
      end

      private

      def set_purchase
        @purchase = Purchase.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {
          status: 'error',
          message: 'Purchase not found'
        }, status: :not_found
        return false
      end

      def purchase_params
        params.require(:purchase).permit(:customer_id, :product_id, :quantity, :total_amount, :purchase_date)
      end

      def apply_filters(purchases)
        if params[:date_from].present? && params[:date_to].present?
          begin
            date_from = Date.parse(params[:date_from])
            date_to = Date.parse(params[:date_to])
            purchases = purchases.by_date_range(date_from, date_to)
          rescue Date::Error
            return purchases.none
          end
        end
        purchases = purchases.by_customer(params[:customer_id]) if params[:customer_id].present?
        purchases = purchases.by_category(params[:category_id]) if params[:category_id].present?
        purchases = purchases.joins(product: :created_by).where(products: { created_by_id: params[:admin_id] }) if params[:admin_id].present?
        purchases
      end

      def aggregate_purchases_by_granularity(purchases, granularity)
        case granularity
        when 'hour'
          purchases.group("DATE_TRUNC('hour', purchase_date)")
                  .count
                  .transform_keys { |k| k.strftime('%Y-%m-%d %H:00') }
        when 'day'
          purchases.group("DATE(purchase_date)")
                  .count
                  .transform_keys { |k| k.strftime('%Y-%m-%d') }
        when 'week'
          purchases.group("DATE_TRUNC('week', purchase_date)")
                  .count
                  .transform_keys { |k| k.strftime('%Y-%m-%d') }
        when 'year'
          purchases.group("DATE_TRUNC('year', purchase_date)")
                  .count
                  .transform_keys { |k| k.strftime('%Y') }
        end
      end

      def purchase_response(purchase)
        {
          id: purchase.id,
          customer: {
            id: purchase.customer.id,
            name: purchase.customer.name,
            email: purchase.customer.email
          },
          product: {
            id: purchase.product.id,
            name: purchase.product.name,
            price: purchase.product.price,
            categories: purchase.product.categories.map { |category| category_response(category) }
          },
          quantity: purchase.quantity,
          total_amount: purchase.total_amount,
          purchase_date: purchase.purchase_date,
          created_at: purchase.created_at,
          updated_at: purchase.updated_at
        }
      end

      def category_response(category)
        {
          id: category.id,
          name: category.name,
          description: category.description
        }
      end
    end
  end
end
