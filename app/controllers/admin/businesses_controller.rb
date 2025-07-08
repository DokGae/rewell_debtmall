class Admin::BusinessesController < Admin::BaseController
  before_action :set_business, only: [:show, :edit, :update, :destroy]

  def index
    @businesses = Business.includes(:logo_attachment, :products)
    
    # 검색 필터
    if params[:search].present?
      @businesses = @businesses.where("name LIKE ? OR email LIKE ?", 
                                    "%#{params[:search]}%", 
                                    "%#{params[:search]}%")
    end
    
    # 상태 필터
    if params[:status].present?
      @businesses = @businesses.where(status: params[:status])
    end
    
    @businesses = @businesses.page(params[:page])
  end

  def show
  end

  def new
    @business = Business.new
  end

  def create
    @business = Business.new(business_params)
    
    if params[:business][:password].present?
      @business.password = params[:business][:password]
      @business.password_confirmation = params[:business][:password_confirmation]
    end
    
    if @business.save
      redirect_to admin_business_path(@business), notice: "업체가 성공적으로 생성되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    update_params = business_params
    
    if params[:business][:password].present?
      update_params[:password] = params[:business][:password]
      update_params[:password_confirmation] = params[:business][:password_confirmation]
    end
    
    if @business.update(update_params)
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
    params.require(:business).permit(:name, :domain, :description, :email, :phone, 
                                   :address, :total_debt, :status, :logo, :deadline)
  end
end
