class AddDaysToWeeklyAlert < ActiveRecord::Migration
  def self.up
    add_column :weekly_alerts, :sun, :text
    add_column :weekly_alerts, :mon, :text
    add_column :weekly_alerts, :tue, :text
    add_column :weekly_alerts, :wed, :text
    add_column :weekly_alerts, :thu, :text
    add_column :weekly_alerts, :fri, :text
    add_column :weekly_alerts, :sat, :text
  end

  def self.down
  end
end
