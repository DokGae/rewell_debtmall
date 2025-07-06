class BusinessesController < ApplicationController
  before_action :set_business

  def show
    @products = @business.products.available_products
                         .includes(:category, images_attachments: :blob)
    
    
    # 카테고리 필터 (다중 선택 지원)
    if params[:categories].present?
      @products = @products.by_categories(params[:categories])
    elsif params[:category].present?
      @products = @products.by_category(params[:category])
    end
    
    # 가격 범위 필터
    if params[:min_price].present? || params[:max_price].present?
      @products = @products.price_between(params[:min_price], params[:max_price])
    end
    
    # 재고 필터
    if params[:in_stock] == "1"
      @products = @products.in_stock_only
    end
    
    # 할인율 필터
    if params[:min_discount].present?
      @products = @products.by_discount_rate(params[:min_discount].to_i)
    end
    
    # 정렬
    case params[:sort]
    when "price_asc"
      @products = @products.sorted_by_price("asc")
    when "price_desc"
      @products = @products.sorted_by_price("desc")
    else
      @products = @products.sorted_by_created
    end
    
    @products = @products.page(params[:page])
    @categories = @business.products.available_products.distinct.pluck(:category).compact
    
    # 가격 범위 계산 (필터 UI용)
    all_products = @business.products.available_products
    @min_price = all_products.minimum(:sale_price) || 0
    @max_price = all_products.maximum(:sale_price) || 1000000
  end

  def search_suggestions
    @business = Business.friendly.find(params[:business_slug])
    @suggestions = @business.products.available_products
                           .search(params[:q])
                           .limit(5)
                           .pluck(:name, :id)
                           .map { |name, id| { name: name, id: id } }
    
    render json: @suggestions
  end

  private

  def set_business
    @business = Business.friendly.find(params[:business_slug])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "업체를 찾을 수 없습니다."
  end
end
