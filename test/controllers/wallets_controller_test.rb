require "test_helper"

class WalletsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get wallets_show_url
    assert_response :success
  end
end
