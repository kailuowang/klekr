# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20111006024816) do

  create_table "active_admin_comments", :force => true do |t|
    t.integer  "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "collectors", :force => true do |t|
    t.string   "user_id"
    t.string   "user_name"
    t.string   "full_name"
    t.string   "auth_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_login"
    t.boolean  "collection_synced", :default => false
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
    t.integer  "collector_id"
    t.boolean  "collecting",   :default => false
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "date_upload"
    t.string   "url"
    t.text     "pic_info_dump"
    t.boolean  "viewed",        :default => false
    t.string   "owner_name"
    t.float    "stream_rating"
    t.integer  "rating",        :default => 0
    t.integer  "collector_id"
    t.boolean  "collected"
    t.datetime "faved_at"
  end

  add_index "pictures", ["collector_id"], :name => "index_pictures_on_collector_id"
  add_index "pictures", ["date_upload"], :name => "index_pictures_on_date_upload"
  add_index "pictures", ["stream_rating"], :name => "index_pictures_on_stream_rating"
  add_index "pictures", ["url"], :name => "index_pictures_on_url"
  add_index "pictures", ["viewed"], :name => "index_pictures_on_viewed"

  create_table "syncages", :force => true do |t|
    t.integer  "picture_id"
    t.integer  "flickr_stream_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "syncages", ["picture_id", "flickr_stream_id"], :name => "index_syncages_on_picture_id_and_flickr_stream_id"

end
