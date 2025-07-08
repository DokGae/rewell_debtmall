class Admin::DashboardController < Admin::BaseController
  def index
    # 통계 데이터
    @total_businesses = Business.count
    @active_businesses = Business.active.count
    @total_products = Product.count
    @available_products = Product.available.count
    @total_requests = PurchaseRequest.count
    @pending_requests = PurchaseRequest.pending.count
    
    # 최근 구매 문의 (5개)
    @recent_requests = PurchaseRequest.includes(:product => :business)
                                     .recent
                                     .limit(5)
  end
end