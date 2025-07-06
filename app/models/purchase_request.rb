# == Schema Information
#
# Table name: purchase_requests
#
#  id            :integer          not null, primary key
#  product_id    :integer          not null
#  buyer_name    :string
#  buyer_email   :string
#  buyer_phone   :string
#  offered_price :decimal(, )
#  message       :text
#  status        :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_purchase_requests_on_product_id  (product_id)
#

class PurchaseRequest < ApplicationRecord
  belongs_to :product
  
  enum :status, { pending: 0, contacted: 1, negotiating: 2, completed: 3, cancelled: 4 }
  
  validates :buyer_name, presence: true
  validates :buyer_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :buyer_phone, presence: true
  validates :offered_price, numericality: { greater_than: 0 }, allow_nil: true
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :price_offers, -> { where(is_price_offer: true) }
  scope :active_offers, -> { price_offers.where(status: [:pending, :contacted, :negotiating]) }
  
  after_create :update_product_offer_stats, if: :is_price_offer?
  after_update :update_product_offer_stats, if: -> { is_price_offer? && saved_change_to_offered_price? }
  after_destroy :update_product_offer_stats, if: :is_price_offer?
  
  def status_text
    I18n.t("enums.purchase_request.status.#{status}")
  end
  
  def self.status_options
    statuses.map { |key, _| [I18n.t("enums.purchase_request.status.#{key}"), key] }
  end
  
  private
  
  def update_product_offer_stats
    product.update_offer_stats!
  end
end
