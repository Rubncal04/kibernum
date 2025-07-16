module Api
  module V1
    class ProductsController < BaseController
      include CacheInvalidation
      before_action :set_product, only: [:show, :update, :destroy, :add_categories, :remove_categories]

      def index
        page = params[:page] || 1
        per_page = params[:per_page] || 20
        
        cache_key = "products_index:#{page}:#{per_page}:#{Product.maximum(:updated_at)&.to_i}"

        result = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
          @products = Product.includes(:categories, :created_by)
                            .ordered
                            .page(page)
                            .per(per_page)

          {
            products: @products.map { |product| product_response(product) },
            pagination: {
              current_page: @products.current_page,
              total_pages: @products.total_pages,
              total_count: @products.total_count
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
            product: product_response(@product)
          }
        }
      end

      def create
        @product = Product.new(product_params)
        @product.created_by = @current_user

        if @product.save
          invalidate_product_cache
          render json: {
            status: 'success',
            message: 'Product created successfully',
            data: {
              product: product_response(@product)
            }
          }, status: :created
        else
          render json: {
            status: 'error',
            message: 'Product creation failed',
            errors: @product.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        if @product.update(product_params)
          invalidate_product_cache
          render json: {
            status: 'success',
            message: 'Product updated successfully',
            data: {
              product: product_response(@product)
            }
          }
        else
          render json: {
            status: 'error',
            message: 'Product update failed',
            errors: @product.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        if @product.destroy
          invalidate_product_cache
          render json: {
            status: 'success',
            message: 'Product deleted successfully'
          }
        else
          render json: {
            status: 'error',
            message: 'Product deletion failed',
            errors: @product.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def most_purchased_by_category
        result = Rails.cache.fetch("most_purchased_by_category", expires_in: 15.minutes) do
          categories = Category.includes(:products)
          result = {}

          categories.each do |category|
            top_products = category.products
                                  .joins(:purchases)
                                  .group('products.id')
                                  .order('SUM(purchases.quantity) DESC')
                                  .limit(3)
                                  .select('products.*, SUM(purchases.quantity) as total_quantity')

            result[category.name] = top_products.map do |product|
              {
                id: product.id,
                name: product.name,
                total_quantity: product.total_quantity,
                price: product.price,
                total_revenue: product.total_revenue
              }
            end
          end
          result
        end

        render json: {
          status: 'success',
          data: result,
          cached: true
        }
      end

      def top_revenue_by_category
        result = Rails.cache.fetch("top_revenue_by_category", expires_in: 15.minutes) do
          categories = Category.includes(:products)
          result = {}

          categories.each do |category|
            top_products = category.products
                                  .joins(:purchases)
                                  .group('products.id')
                                  .order('SUM(purchases.total_amount) DESC')
                                  .limit(3)
                                  .select('products.*, SUM(purchases.total_amount) as total_revenue')

            result[category.name] = top_products.map do |product|
              {
                id: product.id,
                name: product.name,
                total_revenue: product.total_revenue,
                price: product.price,
                total_quantity: product.total_purchases
              }
            end
          end
          result
        end

        render json: {
          status: 'success',
          data: result,
          cached: true
        }
      end

      def add_categories
        unless @product
          render json: {
            status: 'error',
            message: 'Product not found'
          }, status: :not_found
          return
        end
      
        category_ids = params[:category_ids]
      
        if category_ids.present?
          categories = Category.where(id: category_ids)
      
          if categories.count != category_ids.count
            render json: {
              status: 'error',
              message: 'Some categories were not found',
              errors: "Categories with IDs: #{category_ids - categories.pluck(:id)} not found"
            }, status: :not_found
            return
          end
      
          current_category_ids = @product.categories.pluck(:id)
          
          new_category_ids = category_ids - current_category_ids
          
          if new_category_ids.empty?
            render json: {
              status: 'warning',
              message: 'All specified categories are already associated with this product',
              data: {
                product: product_response(@product)
              }
            }
            return
          end
      
          new_categories = Category.where(id: new_category_ids)
          @product.categories << new_categories
      
          render json: {
            status: 'success',
            message: "Categories added successfully. Added: #{new_category_ids.join(', ')}",
            data: {
              product: product_response(@product),
              added_categories: new_category_ids,
              total_categories: @product.categories.pluck(:id)
            }
          }
        else
          render json: {
            status: 'error',
            message: 'No category IDs provided'
          }, status: :bad_request
        end
      end

      def remove_categories
        unless @product
          render json: {
            status: 'error',
            message: 'Product not found'
          }, status: :not_found
          return
        end

        category_ids = params[:category_ids]
        
        if category_ids.present?
          current_categories = @product.categories

          categories_to_remove = current_categories.where(id: category_ids)

          if categories_to_remove.empty?
            render json: {
              status: 'warning',
              message: 'None of the specified categories are associated with this product',
              data: {
                product: product_response(@product)
              }
            }
            return
          end

          removed_ids = categories_to_remove.pluck(:id)
          @product.categories.delete(categories_to_remove)

          render json: {
            status: 'success',
            message: "Categories removed successfully. Removed: #{removed_ids.join(', ')}",
            data: {
              product: product_response(@product),
              removed_categories: removed_ids,
            }
          }
        else
          render json: {
            status: 'error',
            message: 'No category IDs provided'
          }, status: :bad_request
        end
      end

      private

      def set_product
        @product = Product.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {
          status: 'error',
          message: 'Product not found'
        }, status: :not_found
        return false
      end

      def product_params
        params.require(:product).permit(:name, :description, :price, :stock, category_ids: [])
      end

      def product_response(product)
        {
          id: product.id,
          name: product.name,
          description: product.description,
          price: product.price,
          stock: product.stock,
          available: product.available?,
          low_stock: product.low_stock?,
          categories: product.categories.map { |category| category_response(category) },
          created_by: {
            id: product.created_by.id,
            name: product.created_by.name,
            email: product.created_by.email
          },
          created_at: product.created_at,
          updated_at: product.updated_at
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
