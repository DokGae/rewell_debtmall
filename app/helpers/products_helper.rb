module ProductsHelper
  def hierarchical_category_options_for_product(categories, selected_id = nil, level = 0)
    options = []
    
    categories.each do |category|
      prefix = "　" * level + (level > 0 ? "└ " : "")
      options << [prefix + category.name, category.id]
      
      if category.children.any?
        options += hierarchical_category_options_for_product(
          category.children.sort_by { |c| [c.position || 0, c.name] }, 
          selected_id, 
          level + 1
        )
      end
    end
    
    options
  end
  
  def product_category_select_options(categories, selected_id = nil)
    # 이미 계층구조로 정렬된 카테고리를 받아서 처리
    options = []
    
    categories.each do |category|
      if category.parent_id.nil?
        # 최상위 카테고리
        options << [category.name, category.id]
      elsif category.parent.parent_id.nil?
        # 2단계 카테고리
        options << ["　└ #{category.name}", category.id]
      else
        # 3단계 카테고리
        options << ["　　└ #{category.name}", category.id]
      end
    end
    
    options_for_select(options, selected_id)
  end
end
