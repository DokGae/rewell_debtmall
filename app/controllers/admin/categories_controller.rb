class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: [:edit, :update, :destroy]

  def index
    @categories = Category.includes(:parent, children: [:products, :children], products: []).order(:position, :name)
    @root_categories = @categories.where(parent_id: nil)
  end

  def new
    @category = Category.new
    @categories = Category.all.order(:position, :name)
  end

  def create
    @category = Category.new(category_params)
    
    if @category.save
      redirect_to admin_categories_path, notice: '카테고리가 성공적으로 생성되었습니다.'
    else
      @categories = Category.all.order(:position, :name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = Category.where.not(id: @category.id).order(:position, :name)
  end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_path, notice: '카테고리가 성공적으로 수정되었습니다.'
    else
      @categories = Category.where.not(id: @category.id).order(:position, :name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.children.any?
      redirect_to admin_categories_path, alert: '하위 카테고리가 있는 카테고리는 삭제할 수 없습니다.'
    elsif @category.products.any?
      redirect_to admin_categories_path, alert: '상품이 등록된 카테고리는 삭제할 수 없습니다.'
    else
      @category.destroy
      redirect_to admin_categories_path, notice: '카테고리가 성공적으로 삭제되었습니다.'
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :parent_id, :position, :description)
  end
end