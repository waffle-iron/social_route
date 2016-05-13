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

ActiveRecord::Schema.define(version: 20160513030159) do

  create_table "account_insights", force: :cascade do |t|
    t.string   "account_id"
    t.string   "account_name"
    t.string   "age"
    t.string   "gender"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "actions"
    t.string   "impressions"
    t.float    "spend"
    t.integer  "website_clicks"
    t.string   "date"
  end

  create_table "accounts", force: :cascade do |t|
    t.string   "account_id"
    t.string   "account_status"
    t.float    "age"
    t.string   "amount_spent"
    t.string   "name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "actions", force: :cascade do |t|
    t.string   "account_id"
    t.string   "action_type"
    t.string   "date"
    t.float    "value"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "age"
    t.string   "gender"
  end

  create_table "ad_actions", force: :cascade do |t|
    t.string   "action_type"
    t.float    "value"
    t.string   "account_id"
    t.string   "campaign_id"
    t.string   "campaign_name"
    t.string   "objective"
    t.string   "audience"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "placement"
  end

  create_table "ads", force: :cascade do |t|
    t.string   "date_start"
    t.string   "date_stop"
    t.string   "account_id"
    t.string   "ad_id"
    t.string   "ad_name"
    t.string   "campaign_id"
    t.string   "adset_id"
    t.string   "objective"
    t.integer  "total_actions"
    t.string   "impressions"
    t.float    "spend"
    t.float    "frequency"
    t.integer  "reach"
    t.float    "cpm"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "placement"
    t.string   "campaign_name"
    t.string   "audience"
  end

  create_table "adsets", force: :cascade do |t|
    t.string   "name"
    t.string   "adset_id"
    t.string   "account_id"
    t.string   "campaign_id"
    t.string   "status"
    t.float    "daily_budget"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "audience"
  end

  create_table "campaign_actions", force: :cascade do |t|
    t.string   "action_type"
    t.string   "account_id"
    t.float    "value"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "campaign_id"
    t.string   "objective"
    t.string   "campaign_name"
    t.string   "audience"
    t.float    "spend"
    t.string   "impressions"
  end

  create_table "campaign_insights", force: :cascade do |t|
    t.string   "account_id"
    t.string   "campaign_id"
    t.integer  "website_clicks"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "objective"
    t.string   "campaign_name"
    t.string   "audience"
    t.float    "spend"
    t.string   "impressions"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string   "account_id"
    t.datetime "created_time"
    t.string   "effective_status"
    t.string   "name"
    t.string   "objective"
    t.datetime "start_time"
    t.datetime "stop_time"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "campaign_id"
    t.string   "placement"
    t.integer  "spend"
    t.float    "frequency"
    t.string   "impressions"
    t.float    "cpc"
    t.float    "cpm"
    t.float    "cpp"
    t.integer  "reach"
    t.integer  "total_actions"
    t.string   "audience"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
