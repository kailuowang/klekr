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

ActiveRecord::Schema.define(:version => 20110326164354) do

  create_table "flickr_streams", :force => true do |t|
    t.string   "user_id"
    t.datetime "last_sync"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "username"
    t.string   "user_url"
  end

  create_table "monthly_scores", :force => true do |t|
    t.integer  "month"
    t.integer  "year"
    t.integer  "score",              :default => 0
    t.integer  "num_of_pics",        :default => 0
    t.integer  "flickr_stream_id"
    t.string   "flickr_stream_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pictures", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "date_upload"
    t.string   "url"
    t.text     "pic_info_dump"
    t.boolean  "viewed",        :default => false
    t.string   "owner_name"
  end

  add_index "pictures", ["date_upload"], :name => "index_pictures_on_date_upload"
  add_index "pictures", ["url"], :name => "index_pictures_on_url"

  create_table "syncages", :force => true do |t|
    t.integer  "picture_id"
    t.integer  "flickr_stream_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
