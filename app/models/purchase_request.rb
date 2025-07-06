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
  validates :buyer_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :buyer_phone, presence: true
  validates :offered_price, numericality: { greater_than: 0 }, allow_nil: true
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) if status.present? }
end
