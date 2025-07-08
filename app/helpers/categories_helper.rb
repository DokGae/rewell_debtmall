module CategoriesHelper
  def hierarchical_category_options(categories, selected_id = nil, exclude_id = nil, current_level = 0)
    options = []
    
    categories.each do |category|
      next if category.id == exclude_id
      
      prefix = "　" * current_level + (current_level > 0 ? "└ " : "")
      options << [prefix + category.name, category.id]
      
      if category.children.any?
        options += hierarchical_category_options(category.children.sort_by { |c| [c.position || 0, c.name] }, selected_id, exclude_id, current_level + 1)
      end
    end
    
    options
  end
  
  def category_select_options(categories, selected_id = nil, exclude_id = nil)
    root_categories = categories.select { |c| c.parent_id.nil? }.sort_by { |c| [c.position || 0, c.name] }
    options = [["최상위 카테고리", ""]]
    options += hierarchical_category_options(root_categories, selected_id, exclude_id)
    options_for_select(options, selected_id)
  end
end