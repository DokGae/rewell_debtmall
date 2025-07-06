class Admin::PurchaseRequestsController < Admin::BaseController
  before_action :set_purchase_request, only: [:show, :update]
  before_action :set_business, if: -> { params[:business_id].present? }

  def index
    @purchase_requests = if @business
                          # 특정 업체의 구매 요청만 표시
                          PurchaseRequest.joins(:product)
                                        .where(products: { business_id: @business.id })
                                        .includes(:product)
                                        .recent
                                        .page(params[:page])
                        else
                          # 전체 구매 요청 표시
                          PurchaseRequest.includes(:product => :business)
                                        .recent
                                        .page(params[:page])
                        end
    
    if params[:status].present?
      @purchase_requests = @purchase_requests.by_status(params[:status])
    end
    
    # 차트 데이터 준비
    prepare_chart_data
  end

  def show
  end

  def update
    if @purchase_request.update(purchase_request_params)
      redirect_to admin_purchase_request_path(@purchase_request), 
                  notice: "구매 요청 상태가 업데이트되었습니다."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_business
    @business = Business.friendly.find(params[:business_id])
  end

  def set_purchase_request
    @purchase_request = PurchaseRequest.find(params[:id])
  end

  def purchase_request_params
    params.require(:purchase_request).permit(:status)
  end
  
  def prepare_chart_data
    # 최근 7일간 일별 문의 추이
    dates = (6.days.ago.to_date..Date.current).map { |d| d.strftime("%m/%d") }
    daily_counts = dates.map do |date|
      date_obj = Date.strptime(date + "/#{Date.current.year}", "%m/%d/%Y")
      query = if @business
                PurchaseRequest.joins(:product)
                              .where(products: { business_id: @business.id })
                              .where(created_at: date_obj.beginning_of_day..date_obj.end_of_day)
              else
                PurchaseRequest.where(created_at: date_obj.beginning_of_day..date_obj.end_of_day)
              end
      query.count
    end
    
    @daily_chart_data = {
      labels: dates,
      datasets: [{
        label: '일별 문의',
        data: daily_counts,
        backgroundColor: 'rgba(59, 130, 246, 0.5)',
        borderColor: 'rgb(59, 130, 246)',
        borderWidth: 2
      }]
    }
    
    # 상태별 문의 분포
    status_counts = if @business
                     PurchaseRequest.joins(:product)
                                   .where(products: { business_id: @business.id })
                                   .group(:status).count
                   else
                     PurchaseRequest.group(:status).count
                   end
    
    @status_chart_data = {
      labels: status_counts.keys.map { |k| I18n.t("enums.purchase_request.status.#{k}") },
      datasets: [{
        data: status_counts.values,
        backgroundColor: ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899']
      }]
    }
  end
end
