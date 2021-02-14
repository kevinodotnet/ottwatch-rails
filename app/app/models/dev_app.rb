class DevApp < ApplicationRecord
  has_many :details, class_name: DevAppDetail.name
  serialize :details, JSON

  def latest_details
    details.last.details
  end
end
