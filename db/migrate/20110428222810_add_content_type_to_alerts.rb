class AddContentTypeToAlerts < ActiveRecord::Migration
  def self.up
    add_column :alerts, :content_type, :string
  end

  def self.down
    remove_column :alerts, :content_type
  end
end
