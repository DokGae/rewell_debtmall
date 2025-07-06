# == Schema Information
#
# Table name: products
#
#  id              :integer          not null, primary key
#  business_id     :integer          not null
#  name            :string
#  description     :text
#  original_price  :decimal(, )
#  sale_price      :decimal(, )
#  category        :string
#  status          :integer
#  featured        :boolean
#  stock_quantity  :integer
#  specifications  :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  category_id     :integer
#  image_positions :text
#
# Indexes
#
#  index_products_on_business_id  (business_id)
#  index_products_on_category_id  (category_id)
#

class Product < ApplicationRecord
  belongs_to :business
  belongs_to :category, optional: true
  has_many :purchase_requests, dependent: :destroy
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_fill: [300, 300], convert: :webp
    attachable.variant :medium, resize_to_fill: [600, 600], convert: :webp
    attachable.variant :large, resize_to_limit: [1200, 1200], convert: :webp
    attachable.variant :display, resize_to_limit: [800, 800], convert: :webp
  end
  
  serialize :image_positions, coder: JSON, type: Array

  enum :status, { available: 0, sold: 1, reserved: 2, hidden: 3 }

  validates :name, presence: true
  validates :original_price, presence: true, numericality: { greater_than: 0 }
  validates :sale_price, presence: true, numericality: { greater_than: 0 }
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :available_products, -> { where(status: :available) }
  scope :featured, -> { where(featured: true) }
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :by_categories, ->(categories) { where(category: categories) if categories.present? }
  scope :sorted_by_price, ->(direction = "asc") { order(sale_price: direction) }
  scope :sorted_by_created, -> { order(created_at: :desc) }
  scope :search, ->(query) {
    return all if query.blank?
    where("name LIKE ? OR description LIKE ?", "%#{query}%", "%#{query}%")
  }
  scope :price_between, ->(min, max) {
    return all if min.blank? && max.blank?
    query = all
    query = query.where("sale_price >= ?", min) if min.present?
    query = query.where("sale_price <= ?", max) if max.present?
    query
  }
  scope :in_stock_only, -> { where("stock_quantity IS NULL OR stock_quantity > 0") }
  scope :by_discount_rate, ->(min_rate) {
    return all if min_rate.blank?
    where("(original_price - sale_price) / CAST(original_price AS FLOAT) * 100 >= ?", min_rate)
  }

  def discount_percentage
    return 0 if original_price.zero?
    ((original_price - sale_price) / original_price * 100).round
  end

  def in_stock?
    stock_quantity.nil? || stock_quantity > 0
  end
  
  def out_of_stock?
    !in_stock?
  end
  
  def low_stock?
    stock_quantity.present? && stock_quantity > 0 && stock_quantity <= 5
  end
  
  def stock_status
    return :out_of_stock if out_of_stock?
    return :low_stock if low_stock?
    :in_stock
  end
  
  def stock_display
    return "품절" if out_of_stock?
    return "재고 #{stock_quantity}개" if stock_quantity.present?
    "재고 있음"
  end
  
  def ordered_images
    return images unless image_positions.present?
    
    # Get all image signed_ids
    all_image_ids = images.map(&:signed_id)
    
    # Order by positions array, with unpositioned images at the end
    ordered_ids = image_positions & all_image_ids
    remaining_ids = all_image_ids - ordered_ids
    final_order = ordered_ids + remaining_ids
    
    # Return images in the correct order
    final_order.map { |signed_id| images.find { |img| img.signed_id == signed_id } }.compact
  end
  
  def update_image_positions(positions)
    self.image_positions = positions
    save
  end
  
  def primary_image
    ordered_images.first
  end
  
  def update_offer_stats!
    active_offers = purchase_requests.active_offers
    
    self.offer_count = active_offers.count
    self.max_offer_price = active_offers.maximum(:offered_price)
    
    save!
  end
  
  def has_offers?
    offer_count > 0
  end
  
  def offer_display
    return nil unless has_offers?
    
    if offer_count >= 5
      "🔥 #{offer_count}명 제안중 • 경쟁 치열"
    elsif offer_count >= 3
      "🔥 #{offer_count}명 제안중"
    else
      "💰 #{offer_count}명 제안중"
    end
  end
  
  def offer_detail_display
    return nil unless has_offers?
    
    if offer_count >= 5
      "현재 #{offer_count}명이 가격을 제안했습니다 🔥 경쟁이 치열합니다"
    else
      "현재 #{offer_count}명이 가격을 제안했습니다"
    end
  end
  
  def status_text
    I18n.t("enums.product.status.#{status}")
  end
  
  def self.status_options
    statuses.map { |key, _| [I18n.t("enums.product.status.#{key}"), key] }
  end
end
