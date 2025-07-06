class PurchaseRequestsController < ApplicationController
  before_action :set_business_and_product

  def create
    @purchase_request = @product.purchase_requests.build(purchase_request_params)
    
    if @purchase_request.save
      redirect_to business_product_path(@business, @product), 
                  notice: "구매 요청이 성공적으로 접수되었습니다. 곧 연락드리겠습니다."
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
