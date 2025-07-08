Rails.application.routes.draw do
  devise_for :admins
  devise_for :businesses, path: 'business', controllers: {
    sessions: 'business/sessions'
  }
  
  # Admin routes
  namespace :admin do
    resources :businesses do
      resources :products
      resources :purchase_requests, only: [:index, :show]
    end
    resources :categories
    resources :purchase_requests, only: [:index, :show, :update]
    get 'dashboard', to: 'dashboard#index'
    root "dashboard#index"
  end
  
  # Business admin routes
  namespace :business do
    get 'dashboard', to: 'dashboard#index'
    resources :products
    root "dashboard#index"
  end
  
  # Public routes
  root "home#index"
  
  # Business-specific routes (/:business_slug)
  scope "/:business_slug" do
    get "/", to: "businesses#show", as: :business
    get "/search_suggestions", to: "businesses#search_suggestions", as: :business_search_suggestions
    get "/products/:id", to: "products#show", as: :public_business_product
    post "/products/:id/purchase_requests", to: "purchase_requests#create", as: :public_business_product_purchase_requests
    
    # Business admin login (wrapped in devise_scope)
    devise_scope :business do
      get "/admin", to: "business/sessions#new", as: :business_admin_login
    end
  end
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
