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

require "test_helper"

class PurchaseRequestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
