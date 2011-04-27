class CreateNews < ActiveRecord::Migration
  def self.up
    create_table :news do |t|
      t.string :user_id
      t.boolean :news

      t.timestamps
    end
  end

  def self.down
    drop_table :news
  end
end
