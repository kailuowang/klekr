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

ActiveRecord::Schema.define(:version => 20110730132423) do

  create_table "collectors", :force => true do |t|
    t.string   "user_id"
    t.string   "user_name"
    t.string   "full_name"
    t.string   "auth_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "collectors", ["user_id"], :name => "index_collectors_on_user_id", :unique => true

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "flickr_streams", :force => true do |t|
    t.string   "user_id"
    t.datetime "last_sync"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "username"
    t.string   "user_url"
    t.integer  "collector_id"
    t.boolean  "collecting",   :default => true
  end

  add_index "flickr_streams", ["collector_id"], :name => "index_flickr_streams_on_collector_id"

  create_table "monthly_scores", :force => true do |t|
    t.integer  "month"
    t.integer  "year"
    t.float    "score",              :default => 0.0
    t.integer  "num_of_pics",        :default => 0
    t.integer  "flickr_stream_id"
    t.string   "flickr_stream_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pictures", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "date_upload"
    t.text     "pic_info_dump"
    t.boolean  "viewed",        :default => false
    t.string   "owner_name"
    t.float    "stream_rating"
    t.integer  "rating",        :default => 0
    t.integer  "collector_id"
  end

  add_index "pictures", ["collector_id"], :name => "index_pictures_on_collector_id"
  add_index "pictures", ["date_upload"], :name => "index_pictures_on_date_upload"
  add_index "pictures", ["stream_rating"], :name => "index_pictures_on_stream_rating"
  add_index "pictures", ["url"], :name => "index_pictures_on_url"
  add_index "pictures", ["viewed"], :name => "index_pictures_on_viewed"

  create_table "syncages", :force => true do |t|
    t.integer  "picture_id"
    t.integer  "flickr_stream_id"
    t.string   "flickr_stream_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "syncages", ["picture_id", "flickr_stream_id"], :name => "index_syncages_on_picture_id_and_flickr_stream_id"

end
