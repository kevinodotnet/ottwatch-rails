class CreateDevAppDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :dev_app_details do |t|
      t.bigint :dev_app_id
      t.text :details

      t.timestamps
    end
  end
end
