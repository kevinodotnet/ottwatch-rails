class DevAppsController < ApplicationController
  def index
    @foo = Time.now.utc.to_s
  end
end
