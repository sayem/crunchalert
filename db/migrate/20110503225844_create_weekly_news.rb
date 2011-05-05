class CreateWeeklyNews < ActiveRecord::Migration
  def self.up
    create_table :weekly_news do |t|
      t.text :weekly_data

      t.timestamps
    end
  end

  def self.down
    drop_table :weekly_news
  end
end
