class Business::DashboardController < Business::BaseController
  def index
    @business = current_business
    @total_products = @business.products.count
    @active_products = @business.products.available.count
    @total_purchase_requests = PurchaseRequest.joins(:product).where(products: { business_id: @business.id }).count
    
    # 상품별 제안 현황
    @products_with_requests = @business.products
      .left_joins(:purchase_requests)
      .group('products.id')
      .select('products.*, COUNT(purchase_requests.id) as requests_count, MAX(purchase_requests.offered_price) as max_offer')
      .order('requests_count DESC')
      .limit(10)
    
    # 최근 제안 받은 상품
    @recent_requests = PurchaseRequest
      .joins(:product)
      .where(products: { business_id: @business.id })
      .includes(:product)
      .order(created_at: :desc)
      .limit(5)
  end
end