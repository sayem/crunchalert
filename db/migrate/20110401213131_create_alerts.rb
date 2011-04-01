class CreateAlerts < ActiveRecord::Migration
  def self.up
    create_table :alerts do |t|
      t.string :content
      t.integer :user_id

      t.timestamps
    end
    add_index :alerts, :user_id
  end

  def self.down
    drop_table :alerts
  end
end
