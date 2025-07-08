class ProductsController < ApplicationController
  before_action :set_business_and_product

  def show
    @purchase_request = PurchaseRequest.new
  end

  private

  def set_business_and_product
    @business = Business.find_by!(domain: params[:business_slug])
    @product = @business.products.includes(:category, images_attachments: :blob).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "상품을 찾을 수 없습니다."
  end
end
