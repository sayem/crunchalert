# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110507023235) do

  create_table "alerts", :force => true do |t|
    t.string   "content"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "freq"
    t.boolean  "news"
    t.string   "content_type"
  end

  add_index "alerts", ["user_id"], :name => "index_alerts_on_user_id"

  create_table "news", :force => true do |t|
    t.string   "user_id"
    t.boolean  "news"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "freq"
  end

  create_table "pictures", :force => true do |t|
    t.string   "content"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "hashed_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

  create_table "weekly_alerts", :force => true do |t|
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "sun"
    t.text     "mon"
    t.text     "tue"
    t.text     "wed"
    t.text     "thu"
    t.text     "fri"
    t.text     "sat"
  end

  create_table "weekly_news", :force => true do |t|
    t.text     "weekly_data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "sun"
    t.text     "mon"
    t.text     "tue"
    t.text     "wed"
    t.text     "thu"
    t.text     "fri"
    t.text     "sat"
  end

end
