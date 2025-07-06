class Admin::ProductsController < Admin::BaseController
  before_action :set_business
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = @business.products
    
    # 검색
    if params[:search].present?
      @products = @products.search(params[:search])
    end
    
    # 카테고리 필터
    if params[:category_id].present?
      @products = @products.where(category_id: params[:category_id])
    end
    
    # 상태 필터
    if params[:status].present?
      @products = @products.where(status: params[:status])
    end
    
    # 재고 필터
    if params[:in_stock].present?
      @products = @products.in_stock_only
    end
    
    # 정렬
    case params[:sort]
    when 'price_asc'
      @products = @products.sorted_by_price('asc')
    when 'price_desc'
      @products = @products.sorted_by_price('desc')
    when 'name'
      @products = @products.order(:name)
    else
      @products = @products.sorted_by_created
    end
    
    @products = @products.includes(:category, images_attachments: :blob).page(params[:page])
    @categories = Category.active.ordered.includes(parent: :parent)
  end

  def show
  end

  def new
    @product = @business.products.build
    @categories = Category.active.ordered.includes(parent: :parent)
  end

  def create
    @product = @business.products.build(product_params)
    
    # 이미지 처리
    if params[:product][:images].present?
      # 실제 파일 객체만 필터링
      valid_images = params[:product][:images].select do |image|
        image.is_a?(ActionDispatch::Http::UploadedFile)
      end
      @product.images.attach(valid_images) if valid_images.any?
    end
    
    if @product.save
      redirect_to admin_business_product_path(@business, @product), 
                  notice: "상품이 성공적으로 등록되었습니다."
    else
      @categories = Category.active.ordered.includes(parent: :parent)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = Category.active.ordered.includes(parent: :parent)
  end

  def update
    # 이미지 삭제 처리를 먼저 실행
    if params[:product][:remove_images].present?
      handle_image_removal
    end
    
    # 이미지 순서 업데이트
    if params[:product][:image_order].present? && params[:product][:image_order] != ""
      @product.update_image_positions(params[:product][:image_order].split(','))
    end
    
    # 새 이미지 추가 (기존 이미지는 유지)
    if params[:product][:images].present?
      # 빈 문자열과 문자열 파일명 필터링, 실제 파일 객체만 선택
      new_images = params[:product][:images].select do |image|
        image.is_a?(ActionDispatch::Http::UploadedFile)
      end
      
      if new_images.any?
        @product.images.attach(new_images)
      end
      params[:product].delete(:images)  # update에서 images 파라미터 제거
    end
    
    if @product.update(product_params)
      redirect_to admin_business_product_path(@business, @product), 
                  notice: "상품 정보가 수정되었습니다."
    else
      @categories = Category.active.ordered.includes(parent: :parent)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to admin_business_products_path(@business), notice: "상품이 삭제되었습니다."
  end

  private

  def set_business
    @business = Business.friendly.find(params[:business_id])
  end

  def set_product
    @product = @business.products.includes(:category, images_attachments: :blob).find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :original_price, :sale_price, 
                                  :category_id, :status, :featured, :stock_quantity, 
                                  :specifications)
  end
  
  def handle_image_removal
    params[:product][:remove_images].each_with_index do |remove, index|
      if remove == "1" && @product.images[index]
        @product.images[index].purge_later
      end
    end
  end
  
  def handle_image_order
    image_positions = params[:product][:image_order].split(',')
    @product.update_image_positions(image_positions)
  end
end
