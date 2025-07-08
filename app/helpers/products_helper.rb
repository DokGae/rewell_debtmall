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
    root_categories = categories.select { |c| c.parent_id.nil? }.sort_by { |c| [c.position || 0, c.name] }
    options = hierarchical_category_options_for_product(root_categories, selected_id)
    options_for_select(options, selected_id)
  end
end
