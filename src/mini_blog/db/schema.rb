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

ActiveRecord::Schema.define(version: 1) do

  create_table "comments", force: true do |t|
    t.integer  "post_id",     null: false
    t.integer  "user_id",     null: false
    t.string   "content",     null: false
    t.datetime "created_at",  null: false
    t.datetime "modified_at", null: false
  end

  create_table "images", force: true do |t|
    t.integer  "subject_id",               null: false
    t.string   "subject_type", limit: 60,  null: false
    t.string   "name",         limit: 100, null: false
    t.string   "url",          limit: 100, null: false
    t.datetime "created_at",               null: false
    t.datetime "modified_at",              null: false
  end

  create_table "posts", force: true do |t|
    t.integer  "user_id",                                          null: false
    t.string   "title",             limit: 250,                    null: false
    t.text     "short_description",                                null: false
    t.text     "content",           limit: 2147483647,             null: false
    t.integer  "status",            limit: 1,          default: 1, null: false
    t.datetime "created_at",                                       null: false
    t.datetime "modified_at",                                      null: false
  end

  add_index "posts", ["content"], name: "content", type: :fulltext
  add_index "posts", ["title", "content", "short_description"], name: "title_2", type: :fulltext
  add_index "posts", ["title", "short_description", "content"], name: "title", type: :fulltext

  create_table "profiles", force: true do |t|
    t.integer  "user_id",                             null: false
    t.string   "first_name",  limit: 60,              null: false
    t.string   "last_name",   limit: 60,              null: false
    t.integer  "gender",      limit: 1,   default: 1, null: false
    t.string   "address",     limit: 250
    t.datetime "birth_day"
    t.string   "email",       limit: 60,              null: false
    t.string   "phone",       limit: 20,              null: false
    t.datetime "created_at",                          null: false
    t.datetime "modified_at",                         null: false
  end

  add_index "profiles", ["first_name", "last_name"], name: "first_name", type: :fulltext

  create_table "users", force: true do |t|
    t.string   "user_type",     limit: 20,  default: "normal", null: false
    t.string   "username",      limit: 30,                     null: false
    t.string   "salt_password", limit: 200,                    null: false
    t.string   "password",      limit: 200,                    null: false
    t.string   "token",         limit: 200
    t.datetime "created_at",                                   null: false
    t.datetime "modified_at",                                  null: false
  end

  add_index "users", ["username"], name: "username", type: :fulltext
  add_index "users", ["username"], name: "username_2", type: :fulltext

end
