class Business::ProductsController < Business::BaseController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = current_business.products.includes(category: :parent, images_attachments: :blob)
    
    if params[:search].present?
      @products = @products.where("name LIKE ? OR description LIKE ?", 
                                  "%#{params[:search]}%", 
                                  "%#{params[:search]}%")
    end
    
    if params[:category_id].present?
      @products = @products.where(category_id: params[:category_id])
    end
    
    if params[:status].present?
      @products = @products.where(status: params[:status])
    end
    
    if params[:in_stock] == "1"
      @products = @products.where("stock_quantity > 0")
    end
    
    @products = @products.page(params[:page])
    @categories = Category.includes(:children).all
  end

  def show
    @purchase_requests = @product.purchase_requests
      .order(offered_price: :desc)
      .page(params[:page])
  end

  def new
    @product = current_business.products.build
    @categories = Category.includes(:parent).all
  end

  def create
    @product = current_business.products.build(product_params)
    
    if @product.save
      redirect_to business_product_path(@product), notice: "상품이 성공적으로 등록되었습니다."
    else
      @categories = Category.includes(:parent).all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = Category.includes(:parent).all
  end

  def update
    if @product.update(product_params)
      redirect_to business_product_path(@product), notice: "상품 정보가 수정되었습니다."
    else
      @categories = Category.includes(:parent).all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to business_products_path, notice: "상품이 삭제되었습니다."
  end

  private

  def set_product
    @product = current_business.products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :original_price, :sale_price, 
                                   :stock_quantity, :category_id, :status, :featured,
                                   :specifications, images: [], 
                                   remove_images: [], image_order: [])
  end
end