class ChangeWeeklyAlerts < ActiveRecord::Migration
  def self.up
    change_table :weekly_alerts do |t|
      t.remove(:weekly_data)
    end
  end

  def self.down
  end
end
