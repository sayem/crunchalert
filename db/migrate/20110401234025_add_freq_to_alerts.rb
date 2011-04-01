class AddFreqToAlerts < ActiveRecord::Migration
  def self.up
    add_column :alerts, :freq, :boolean
  end

  def self.down
    remove_column :alerts, :freq
  end
end
