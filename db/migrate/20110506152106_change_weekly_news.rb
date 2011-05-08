class ChangeWeeklyNews < ActiveRecord::Migration
  def self.up
    change_table :weekly_news do |t|
      t.remove(:weekly_data)
    end
  end

  def self.down
  end
end
