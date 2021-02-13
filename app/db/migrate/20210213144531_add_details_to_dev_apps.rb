class AddDetailsToDevApps < ActiveRecord::Migration[6.1]
  def change
    add_column :dev_apps, :details, :text
  end
end
