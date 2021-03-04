class DevAppsController < ApplicationController
  def index
    @now = Time.now.utc.to_i
  end
end
