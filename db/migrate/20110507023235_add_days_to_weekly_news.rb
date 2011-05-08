class AddDaysToWeeklyNews < ActiveRecord::Migration
  def self.up
    add_column :weekly_news, :sun, :text
    add_column :weekly_news, :mon, :text
    add_column :weekly_news, :tue, :text
    add_column :weekly_news, :wed, :text
    add_column :weekly_news, :thu, :text
    add_column :weekly_news, :fri, :text
    add_column :weekly_news, :sat, :text
  end

  def self.down
  end
end
