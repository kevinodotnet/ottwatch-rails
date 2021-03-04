require "test_helper"

class DevAppsControllerTest < ActionDispatch::IntegrationTest
  test "get :index returns a page" do
    freeze_time do
      now = Time.now.utc.to_i
      get '/devapps/'
      assert_response :success
      assert response.body.match(/Now is #{now}/)
    end

  end
end
