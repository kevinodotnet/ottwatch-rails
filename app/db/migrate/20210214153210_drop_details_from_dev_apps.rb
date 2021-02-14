class DropDetailsFromDevApps < ActiveRecord::Migration[6.1]
  def change
    remove_column :dev_apps, :details, :text
  end
end
