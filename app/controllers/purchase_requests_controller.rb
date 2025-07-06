class PurchaseRequestsController < ApplicationController
  before_action :set_business_and_product

  def create
    @purchase_request = @product.purchase_requests.build(purchase_request_params)
    
    # offered_price가 있으면 가격 제안으로 처리
    if @purchase_request.offered_price.present?
      @purchase_request.is_price_offer = true
    end
    
    if @purchase_request.save
      notice_message = if @purchase_request.is_price_offer?
        "가격 제안이 성공적으로 접수되었습니다. 판매자가 검토 후 연락드릴 예정입니다."
      else
        "구매 요청이 성공적으로 접수되었습니다. 곧 연락드리겠습니다."
      end
      
      redirect_to business_product_path(@business, @product), 
                  notice: notice_message
    else
      render "products/show", status: :unprocessable_entity
    end
  end

  private

  def set_business_and_product
    @business = Business.friendly.find(params[:business_slug])
    @product = @business.products.includes(:category, images_attachments: :blob).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "상품을 찾을 수 없습니다."
  end

  def purchase_request_params
    params.require(:purchase_request).permit(:buyer_name, :buyer_email, :buyer_phone, 
                                           :offered_price, :message)
  end
end
