class Admin::BusinessesController < Admin::BaseController
  before_action :set_business, only: [:show, :edit, :update, :destroy]

  def index
    @businesses = Business.includes(:logo_attachment, :products).page(params[:page])
    
    # 대시보드 통계
    @total_businesses = Business.count
    @active_businesses = Business.active.count
    @total_products = Product.count
    @available_products = Product.available_products.count
    @total_requests = PurchaseRequest.count
    @pending_requests = PurchaseRequest.pending.count
    
    # 최근 구매 문의
    @recent_requests = PurchaseRequest.includes(:product, product: :business)
                                     .order(created_at: :desc)
                                     .limit(5)
    
    # 업체별 상품 통계
    @business_stats = Business.left_joins(:products)
                            .group(:id)
                            .select('businesses.*, COUNT(products.id) as products_count')
                            .order('products_count DESC')
                            .limit(5)
  end

  def show
  end

  def new
    @business = Business.new
  end

  def create
    @business = Business.new(business_params)
    
    if @business.save
      redirect_to admin_business_path(@business), notice: "업체가 성공적으로 생성되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @business.update(business_params)
      redirect_to admin_business_path(@business), notice: "업체 정보가 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @business.destroy
    redirect_to admin_businesses_path, notice: "업체가 삭제되었습니다."
  end

  private

  def set_business
    @business = Business.friendly.find(params[:id])
  end

  def business_params
    params.require(:business).permit(:name, :description, :email, :phone, 
                                   :address, :total_debt, :status, :logo)
  end
end
