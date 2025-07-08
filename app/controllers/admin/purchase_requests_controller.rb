class Admin::PurchaseRequestsController < Admin::BaseController
  before_action :set_purchase_request, only: [:show, :update]
  before_action :set_business, if: -> { params[:business_id].present? && params[:action] != 'index' }

  def index
    @purchase_requests = if @business
                          # 특정 업체의 구매 요청만 표시 (라우트의 business_id를 통해 접근한 경우)
                          PurchaseRequest.joins(:product)
                                        .where(products: { business_id: @business.id })
                                        .includes(product: [:business, { images_attachments: :blob }])
                                        .recent
                                        .page(params[:page])
                        elsif params[:product_id].present?
                          # 특정 상품의 구매 요청만 표시
                          @product = Product.find(params[:product_id])
                          PurchaseRequest.where(product_id: params[:product_id])
                                        .includes(product: [:business, { images_attachments: :blob }])
                                        .recent
                                        .page(params[:page])
                        elsif params[:business_id].present? && !@business
                          # 드롭다운에서 선택한 업체 필터링 (파라미터로만 전달된 경우)
                          PurchaseRequest.joins(:product)
                                        .where(products: { business_id: params[:business_id] })
                                        .includes(product: [:business, { images_attachments: :blob }])
                                        .recent
                                        .page(params[:page])
                        else
                          # 전체 구매 요청을 업체별로 그룹화
                          if params[:view] == 'grouped'
                            # 업체별 그룹 뷰
                            @businesses_with_requests = Business.joins(products: :purchase_requests)
                                                               .distinct
                                                               .includes(products: :purchase_requests)
                                                               .order(:name)
                                                               .page(params[:page])
                            
                            # 선택된 업체가 있으면 해당 업체의 구매요청도 로드
                            if params[:selected_business_id].present?
                              @selected_business = Business.find(params[:selected_business_id])
                              @selected_business_requests = PurchaseRequest.joins(:product)
                                                                          .where(products: { business_id: @selected_business.id })
                                                                          .includes(product: [:business, { images_attachments: :blob }])
                                                                          .recent
                                                                          .limit(10)
                            end
                            
                            # AJAX 요청인 경우 부분 렌더링
                            if request.xhr?
                              render partial: 'business_requests', locals: { business: @selected_business, requests: @selected_business_requests }
                              return
                            end
                          else
                            # 기존 리스트 뷰
                            PurchaseRequest.includes(product: [:business, { images_attachments: :blob }])
                                          .recent
                                          .page(params[:page])
                          end
                        end
    
    if params[:status].present? && params[:view] != 'grouped'
      @purchase_requests = @purchase_requests.by_status(params[:status])
    end
    
    # 차트 데이터 준비
    prepare_chart_data unless params[:view] == 'grouped'
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
