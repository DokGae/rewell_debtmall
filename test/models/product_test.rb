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

require "test_helper"

class ProductTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
