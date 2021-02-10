class CreateDevApps < ActiveRecord::Migration[6.1]
  def change
    create_table :dev_apps do |t|
      t.string :app_id, :limit => 32
      t.string :dev_id, :limit => 32
      t.string :app_type, :limit => 32
      t.text :description
      t.date :received_on
      t.timestamps
    end
  end
end
