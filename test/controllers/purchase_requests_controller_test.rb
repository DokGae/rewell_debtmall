require "test_helper"

class PurchaseRequestsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get purchase_requests_create_url
    assert_response :success
  end
end
