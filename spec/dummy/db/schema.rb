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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131007190217) do

  create_table "thredded_attachments", force: true do |t|
    t.string   "attachment"
    t.string   "content_type"
    t.integer  "file_size"
    t.integer  "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thredded_categories", force: true do |t|
    t.integer  "messageboard_id", null: false
    t.string   "name",            null: false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thredded_images", force: true do |t|
    t.integer  "post_id"
    t.integer  "width"
    t.integer  "height"
    t.string   "orientation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thredded_messageboard_preferences", force: true do |t|
    t.boolean  "notify_on_mention", default: true
    t.boolean  "notify_on_message", default: true
    t.string   "filter",            default: "markdown", null: false
    t.integer  "user_id",                                null: false
    t.integer  "messageboard_id",                        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thredded_messageboard_preferences", ["messageboard_id"], name: "index_thredded_messageboard_preferences_on_messageboard_id", using: :btree
  add_index "thredded_messageboard_preferences", ["user_id"], name: "index_thredded_messageboard_preferences_on_user_id", using: :btree

  create_table "thredded_messageboards", force: true do |t|
    t.string   "name",                                     null: false
    t.string   "slug"
    t.text     "description"
    t.string   "security",           default: "public"
    t.string   "posting_permission", default: "anonymous"
    t.integer  "topics_count",       default: 0
    t.integer  "posts_count",        default: 0
    t.boolean  "closed",             default: false,       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thredded_messageboards", ["closed"], name: "index_thredded_messageboards_on_closed", using: :btree

  create_table "thredded_post_notifications", force: true do |t|
    t.string   "email",      null: false
    t.integer  "post_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thredded_posts", force: true do |t|
    t.integer  "user_id"
    t.string   "user_email"
    t.text     "content"
    t.string   "ip"
    t.string   "filter",          default: "markdown"
    t.string   "source",          default: "web"
    t.integer  "topic_id",                             null: false
    t.integer  "messageboard_id",                      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thredded_private_users", force: true do |t|
    t.integer  "private_topic_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thredded_roles", force: true do |t|
    t.string   "level"
    t.integer  "user_id"
    t.integer  "messageboard_id"
    t.datetime "last_seen"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thredded_roles", ["messageboard_id"], name: "index_thredded_roles_on_messageboard_id", using: :btree
  add_index "thredded_roles", ["user_id"], name: "index_thredded_roles_on_user_id", using: :btree

  create_table "thredded_topic_categories", force: true do |t|
    t.integer "topic_id",    null: false
    t.integer "category_id", null: false
  end

  create_table "thredded_topics", force: true do |t|
    t.integer  "user_id",                              null: false
    t.integer  "last_user_id",                         null: false
    t.string   "title",                                null: false
    t.string   "slug",                                 null: false
    t.integer  "messageboard_id",                      null: false
    t.integer  "posts_count",     default: 0,          null: false
    t.boolean  "sticky",          default: false,      null: false
    t.boolean  "locked",          default: false,      null: false
    t.string   "hash_id",                              null: false
    t.string   "state",           default: "approved", null: false
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thredded_user_details", force: true do |t|
    t.integer  "user_id",                            null: false
    t.datetime "latest_activity_at"
    t.integer  "posts_count",        default: 0
    t.integer  "topics_count",       default: 0
    t.boolean  "superadmin",         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thredded_user_details", ["latest_activity_at"], name: "index_thredded_user_details_on_latest_activity_at", using: :btree
  add_index "thredded_user_details", ["user_id"], name: "index_thredded_user_details_on_user_id", using: :btree

  create_table "thredded_user_preferences", force: true do |t|
    t.integer  "user_id",                                           null: false
    t.string   "time_zone",  default: "Eastern Time (US & Canada)"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thredded_user_preferences", ["user_id"], name: "index_thredded_user_preferences_on_user_id", using: :btree

  create_table "thredded_user_topic_reads", force: true do |t|
    t.integer  "user_id",                 null: false
    t.integer  "topic_id",                null: false
    t.integer  "post_id",                 null: false
    t.integer  "posts_count", default: 0, null: false
    t.integer  "page",        default: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "thredded_user_topic_reads", ["page"], name: "index_thredded_user_topic_reads_on_page", using: :btree
  add_index "thredded_user_topic_reads", ["post_id"], name: "index_thredded_user_topic_reads_on_post_id", using: :btree
  add_index "thredded_user_topic_reads", ["posts_count"], name: "index_thredded_user_topic_reads_on_posts_count", using: :btree
  add_index "thredded_user_topic_reads", ["topic_id"], name: "index_thredded_user_topic_reads_on_topic_id", using: :btree
  add_index "thredded_user_topic_reads", ["user_id"], name: "index_thredded_user_topic_reads_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
