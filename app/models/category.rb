class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Self-referential association for parent/child categories
  belongs_to :parent, class_name: "Category", optional: true
  has_many :children, class_name: "Category", foreign_key: "parent_id", dependent: :destroy
  
  # Validations
  validates :name, presence: true, uniqueness: { scope: :parent_id }
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :root_categories, -> { where(parent_id: nil) }
  scope :ordered, -> { order(:position, :name) }
  
  # Class methods
  def self.tree
    root_categories.includes(:children).ordered
  end
  
  def self.with_ancestors
    includes(:parent)
  end
  
  # Instance methods
  def full_path
    ancestors.reverse.push(self).map(&:name).join(" > ")
  end
  
  def ancestors
    return [] unless parent
    
    # Avoid N+1 by loading all ancestors at once if possible
    result = []
    current = parent
    
    while current
      result << current
      current = current.parent
    end
    
    result
  end
  
  def descendants
    children.flat_map { |child| [child] + child.descendants }
  end
  
  def leaf?
    children.empty?
  end
  
  def root?
    parent_id.nil?
  end
end
