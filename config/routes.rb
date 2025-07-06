Rails.application.routes.draw do
  devise_for :admins
  
  # Admin routes
  namespace :admin do
    resources :businesses do
      resources :products
    end
    resources :purchase_requests, only: [:index, :show, :update]
    root "businesses#index"
  end
  
  # Public routes
  root "home#index"
  
  # Business-specific routes (/:business_slug)
  get "/:business_slug", to: "businesses#show", as: :business
  get "/:business_slug/search_suggestions", to: "businesses#search_suggestions", as: :business_search_suggestions
  get "/:business_slug/products/:id", to: "products#show", as: :business_product
  post "/:business_slug/products/:id/purchase_requests", to: "purchase_requests#create", as: :business_product_purchase_requests
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
