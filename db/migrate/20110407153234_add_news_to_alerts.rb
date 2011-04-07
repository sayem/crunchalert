class AddNewsToAlerts < ActiveRecord::Migration
  def self.up
    add_column :alerts, :news, :boolean
  end

  def self.down
    remove_column :alerts, :news
  end
end
