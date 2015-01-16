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

ActiveRecord::Schema.define(version: 20150116052903) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abuses", force: true do |t|
    t.integer  "user_id"
    t.integer  "abusable_id"
    t.string   "abusable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "addresses", force: true do |t|
    t.boolean  "primary"
    t.integer  "user_id"
    t.string   "country"
    t.string   "state"
    t.string   "city"
    t.integer  "pincode"
    t.text     "full_address"
    t.string   "address_proof_file_name"
    t.string   "address_proof_content_type"
    t.integer  "address_proof_file_size"
    t.datetime "address_proof_updated_at"
    t.datetime "verified_at"
    t.integer  "admin_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "comments", force: true do |t|
    t.integer  "parent_id"
    t.integer  "user_id"
    t.integer  "project_id"
    t.text     "description"
    t.boolean  "spam",           default: false
    t.boolean  "visible_to_all", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted",        default: false
    t.datetime "deleted_at"
    t.integer  "deleted_by"
    t.integer  "abused_count",   default: 0
    t.integer  "admin_user_id"
  end

  create_table "contributions", force: true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.string   "state",      default: "contributed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "amount"
  end

  add_index "contributions", ["project_id"], name: "index_contributions_on_project_id", using: :btree
  add_index "contributions", ["user_id"], name: "index_contributions_on_user_id", using: :btree

  create_table "images", force: true do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "document",           default: false
    t.integer  "imageable_id"
    t.string   "imageable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", force: true do |t|
    t.string   "title"
    t.decimal  "amount_required",              precision: 12, scale: 2
    t.integer  "min_amount_divisor",                                    default: 10
    t.text     "description"
    t.datetime "end_date"
    t.string   "video_link"
    t.datetime "verified_at"
    t.integer  "admin_user_id"
    t.string   "type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "min_amount_per_contribution",  precision: 12, scale: 2
    t.string   "project_picture_file_name"
    t.string   "project_picture_content_type"
    t.integer  "project_picture_file_size"
    t.datetime "project_picture_updated_at"
    t.string   "state",                                                 default: "created"
    t.integer  "collected_amount",                                      default: 0
    t.integer  "contributors_count",                                    default: 0
  end

  add_index "projects", ["state"], name: "index_projects_on_state", using: :btree

  create_table "users", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                        default: "", null: false
    t.string   "encrypted_password",           default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.string   "profile_picture_file_name"
    t.string   "profile_picture_content_type"
    t.integer  "profile_picture_file_size"
    t.datetime "profile_picture_updated_at"
    t.string   "pan_card"
    t.string   "pan_card_copy_file_name"
    t.string   "pan_card_copy_content_type"
    t.integer  "pan_card_copy_file_size"
    t.datetime "pan_card_copy_updated_at"
    t.datetime "pan_verified_at"
    t.integer  "pan_verified_by"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
