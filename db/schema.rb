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

ActiveRecord::Schema.define(version: 2015_01_31_074050) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abuses", force: :cascade do |t|
    t.integer "user_id"
    t.string "abusable_type"
    t.bigint "abusable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["abusable_type", "abusable_id"], name: "index_abuses_on_abusable_type_and_abusable_id"
  end

  create_table "addresses", force: :cascade do |t|
    t.boolean "primary"
    t.bigint "user_id"
    t.string "country"
    t.string "state"
    t.string "city"
    t.integer "pincode"
    t.text "full_address"
    t.string "address_proof_file_name"
    t.string "address_proof_content_type"
    t.bigint "address_proof_file_size"
    t.datetime "address_proof_updated_at"
    t.datetime "verified_at"
    t.integer "admin_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.integer "parent_id"
    t.bigint "user_id"
    t.bigint "project_id"
    t.text "description"
    t.boolean "spam", default: false
    t.boolean "visible_to_all", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "deleted", default: false
    t.datetime "deleted_at"
    t.integer "deleted_by"
    t.integer "abused_count", default: 0
    t.integer "admin_user_id"
    t.index ["project_id"], name: "index_comments_on_project_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "contribution_transactions", force: :cascade do |t|
    t.bigint "contribution_id"
    t.string "action"
    t.integer "amount"
    t.boolean "success"
    t.string "authorization"
    t.string "message"
    t.text "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contribution_id"], name: "index_contribution_transactions_on_contribution_id"
  end

  create_table "contributions", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "user_id"
    t.string "state", default: "contributed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "amount"
    t.string "brand"
    t.date "card_expires_on"
    t.inet "ip_address"
    t.cidr "network_address"
    t.string "stripe_customer_id"
    t.index ["project_id"], name: "index_contributions_on_project_id"
    t.index ["user_id"], name: "index_contributions_on_user_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "images", force: :cascade do |t|
    t.string "image_file_name"
    t.string "image_content_type"
    t.bigint "image_file_size"
    t.datetime "image_updated_at"
    t.boolean "document", default: false
    t.string "imageable_type"
    t.bigint "imageable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "title"
    t.decimal "amount_required", precision: 12, scale: 2
    t.integer "min_amount_divisor", default: 10
    t.text "description"
    t.datetime "end_date"
    t.string "video_link"
    t.datetime "verified_at"
    t.integer "admin_user_id"
    t.string "type"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "min_amount_per_contribution", precision: 12, scale: 2
    t.string "project_picture_file_name"
    t.string "project_picture_content_type"
    t.bigint "project_picture_file_size"
    t.datetime "project_picture_updated_at"
    t.string "state", default: "created"
    t.integer "collected_amount", default: 0
    t.integer "contributors_count", default: 0
    t.index ["state"], name: "index_projects_on_state"
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.string "profile_picture_file_name"
    t.string "profile_picture_content_type"
    t.bigint "profile_picture_file_size"
    t.datetime "profile_picture_updated_at"
    t.string "pan_card"
    t.string "pan_card_copy_file_name"
    t.string "pan_card_copy_content_type"
    t.bigint "pan_card_copy_file_size"
    t.datetime "pan_card_copy_updated_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "pan_verified_at"
    t.integer "pan_verified_by"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
