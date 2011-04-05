class AddContentUniquenessIndex < ActiveRecord::Migration
  def self.up
    add_index :alerts, :content, :unique => true
  end

  def self.down
    remove_index :alerts, :content
  end
end
