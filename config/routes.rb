Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post 'auth/login', to: 'auth#login'
      post "auth/register", to: "auth#register"
      get "auth/me", to: "auth#me"

      resources :products do
        member do
          post "categories", to: "products#add_categories"
          delete "categories", to: "products#remove_categories"
        end
        collection do
          get "most_purchased_by_category", to: "products#most_purchased_by_category"
          get "top_revenue_by_category", to: "products#top_revenue_by_category"
        end
      end
    end
  end

  root to: proc { [200, {}, ['Kibernum E-commerce API']] }
end
