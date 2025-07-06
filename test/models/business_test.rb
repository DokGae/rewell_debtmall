# == Schema Information
#
# Table name: businesses
#
#  id          :integer          not null, primary key
#  name        :string
#  slug        :string
#  description :text
#  email       :string
#  phone       :string
#  address     :text
#  total_debt  :decimal(, )
#  status      :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  deadline    :datetime
#
# Indexes
#
#  index_businesses_on_slug  (slug) UNIQUE
#

require "test_helper"

class BusinessTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
