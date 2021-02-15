require "test_helper"

class DevAppsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get dev_apps_index_url
    assert_response :success
  end
end
