class DevAppDetail < ApplicationRecord
  has_one :dev_app
  serialize :details, JSON
end
