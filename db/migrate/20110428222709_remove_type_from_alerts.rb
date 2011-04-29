class RemoveTypeFromAlerts < ActiveRecord::Migration
  def self.up
    remove_column :alerts, :type
  end

  def self.down
    add_column :alerts, :type, :string
  end
end
