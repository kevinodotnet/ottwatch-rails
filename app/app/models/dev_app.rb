class DevApp < ApplicationRecord
  has_many :dev_app_detail
  serialize :details, JSON
end
