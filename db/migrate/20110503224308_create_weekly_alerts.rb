class CreateWeeklyAlerts < ActiveRecord::Migration
  def self.up
    create_table :weekly_alerts do |t|
      t.string :content
      t.text :weekly_data

      t.timestamps
    end
  end

  def self.down
    drop_table :weekly_alerts
  end
end
