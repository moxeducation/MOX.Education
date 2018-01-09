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

ActiveRecord::Schema.define(version: 20160805134151) do

  create_table "groups", force: :cascade do |t|
    t.string   "name",                 limit: 255, null: false
    t.integer  "admin_id",             limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "picture_file_name",    limit: 255
    t.string   "picture_content_type", limit: 255
    t.integer  "picture_file_size",    limit: 4
    t.datetime "picture_updated_at"
  end

  create_table "memberships", force: :cascade do |t|
    t.string   "type",       limit: 255
    t.boolean  "accepted",               default: false, null: false
    t.integer  "user_id",    limit: 4,                   null: false
    t.integer  "group_id",   limit: 4,                   null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "products", force: :cascade do |t|
    t.integer  "user_id",            limit: 4
    t.string   "title",              limit: 255
    t.integer  "approver_id",        limit: 4
    t.integer  "order",              limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.string   "slug",               limit: 255
    t.boolean  "ready_for_approve"
    t.integer  "group_id",           limit: 4
    t.boolean  "public",                         default: false, null: false
  end

  add_index "products", ["group_id"], name: "index_products_on_group_id", using: :btree
  add_index "products", ["slug"], name: "index_products_on_slug", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.integer  "user_id",            limit: 4
    t.boolean  "approved",                       default: false
  end

  add_index "tags", ["approved"], name: "index_tags_on_approved", using: :btree
  add_index "tags", ["user_id"], name: "index_tags_on_user_id", using: :btree

  create_table "tags_products", id: false, force: :cascade do |t|
    t.integer "tag_id",     limit: 4
    t.integer "product_id", limit: 4
  end

  add_index "tags_products", ["product_id"], name: "index_tags_products_on_product_id", using: :btree
  add_index "tags_products", ["tag_id"], name: "index_tags_products_on_tag_id", using: :btree

  create_table "tiles", force: :cascade do |t|
    t.integer  "product_id",        limit: 4
    t.string   "tile_type",         limit: 255,   default: "text"
    t.string   "title",             limit: 255
    t.string   "title_color",       limit: 255
    t.string   "color",             limit: 255
    t.text     "content",           limit: 65535
    t.integer  "order",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_file_name",    limit: 255
    t.string   "file_content_type", limit: 255
    t.integer  "file_file_size",    limit: 4
    t.datetime "file_updated_at"
    t.integer  "linked_product_id", limit: 4
  end

  add_index "tiles", ["tile_type"], name: "index_tiles_on_tile_type", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",     null: false
    t.string   "encrypted_password",     limit: 255, default: "",     null: false
    t.string   "company_name",           limit: 255
    t.string   "role",                   limit: 255, default: "user"
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,      null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.boolean  "notificable",                        default: true
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
