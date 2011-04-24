class AddFreqToNews < ActiveRecord::Migration
  def self.up
    add_column :news, :freq, :boolean
  end

  def self.down
    remove_column :news, :freq
  end
end
