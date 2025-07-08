module ApplicationHelper
  def highlight_search(text, query)
    return text if query.blank?
    
    highlighted = text.to_s.gsub(/(#{Regexp.escape(query)})/i) do |match|
      content_tag(:mark, match, class: "bg-yellow-500 text-black px-1 rounded")
    end
    
    highlighted.html_safe
  end
  
  def format_currency(amount)
    "₩#{number_with_delimiter(amount || 0)}"
  end
end
