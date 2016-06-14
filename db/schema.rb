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

ActiveRecord::Schema.define(version: 20160614011703) do

  create_table "account_placement_actions", force: :cascade do |t|
    t.string   "account_id",  limit: 191
    t.string   "action_type", limit: 191
    t.float    "value",       limit: 24
    t.string   "placement",   limit: 191
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "account_placements", force: :cascade do |t|
    t.string   "date_start",  limit: 191
    t.string   "date_stop",   limit: 191
    t.string   "account_id",  limit: 191
    t.integer  "impressions", limit: 4
    t.float    "spend",       limit: 24
    t.string   "placement",   limit: 191
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "accounts", force: :cascade do |t|
    t.string   "account_id",     limit: 191
    t.string   "account_status", limit: 191
    t.float    "age",            limit: 24
    t.string   "amount_spent",   limit: 191
    t.string   "name",           limit: 191
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "actions", force: :cascade do |t|
    t.string   "account_id",  limit: 191
    t.string   "action_type", limit: 191
    t.string   "date",        limit: 191
    t.float    "value",       limit: 24
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "age",         limit: 191
    t.string   "gender",      limit: 191
  end

  create_table "ad2_actions", force: :cascade do |t|
    t.string   "account_id",  limit: 191
    t.string   "action_type", limit: 191
    t.float    "value",       limit: 24
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "objective",   limit: 191
    t.string   "audience",    limit: 191
    t.string   "format",      limit: 191
    t.string   "edition",     limit: 191
    t.string   "simple_name", limit: 191
    t.string   "ad_id",       limit: 191
  end

  create_table "ad2_age_and_gender_actions", force: :cascade do |t|
    t.string   "account_id",  limit: 191
    t.string   "action_type", limit: 191
    t.float    "value",       limit: 24
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "objective",   limit: 191
    t.string   "age",         limit: 191
    t.string   "gender",      limit: 191
  end

  create_table "ad2_placement_actions", force: :cascade do |t|
    t.string   "account_id",  limit: 191
    t.string   "action_type", limit: 191
    t.float    "value",       limit: 24
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "objective",   limit: 191
    t.string   "placement",   limit: 191
  end

  create_table "ad2_placements", force: :cascade do |t|
    t.string   "account_id",  limit: 191
    t.string   "campaign_id", limit: 191
    t.string   "adset_id",    limit: 191
    t.string   "ad_id",       limit: 191
    t.string   "ad_name",     limit: 191
    t.string   "objective",   limit: 191
    t.string   "placement",   limit: 191
    t.string   "impressions", limit: 191
    t.float    "spend",       limit: 24
    t.float    "frequency",   limit: 24
    t.integer  "reach",       limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "ad2s", force: :cascade do |t|
    t.string   "account_id",  limit: 191
    t.string   "campaign_id", limit: 191
    t.string   "adset_id",    limit: 191
    t.string   "ad_id",       limit: 191
    t.string   "ad_name",     limit: 191
    t.string   "objective",   limit: 191
    t.string   "placement",   limit: 191
    t.string   "impressions", limit: 191
    t.float    "spend",       limit: 24
    t.float    "frequency",   limit: 24
    t.integer  "reach",       limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "date_start",  limit: 191
    t.string   "date_stop",   limit: 191
    t.string   "audience",    limit: 191
    t.string   "format",      limit: 191
    t.string   "edition",     limit: 191
    t.string   "simple_name", limit: 191
  end

  create_table "ad_account_creatives", force: :cascade do |t|
    t.text     "image_url",     limit: 65535
    t.text     "thumbnail_url", limit: 65535
    t.string   "creative_id",   limit: 191
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "ad_actions", force: :cascade do |t|
    t.string   "action_type",   limit: 191
    t.float    "value",         limit: 24
    t.string   "account_id",    limit: 191
    t.string   "campaign_id",   limit: 191
    t.string   "campaign_name", limit: 191
    t.string   "objective",     limit: 191
    t.string   "audience",      limit: 191
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "placement",     limit: 191
  end

  create_table "ad_creative_lookups", force: :cascade do |t|
    t.string   "ad_id",       limit: 191
    t.string   "creative_id", limit: 191
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "ads", force: :cascade do |t|
    t.string   "date_start",    limit: 191
    t.string   "date_stop",     limit: 191
    t.string   "account_id",    limit: 191
    t.string   "ad_id",         limit: 191
    t.string   "ad_name",       limit: 191
    t.string   "campaign_id",   limit: 191
    t.string   "adset_id",      limit: 191
    t.string   "objective",     limit: 191
    t.integer  "total_actions", limit: 4
    t.string   "impressions",   limit: 191
    t.float    "spend",         limit: 24
    t.float    "frequency",     limit: 24
    t.integer  "reach",         limit: 4
    t.float    "cpm",           limit: 24
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "placement",     limit: 191
    t.string   "campaign_name", limit: 191
    t.string   "audience",      limit: 191
    t.string   "format",        limit: 191
    t.string   "edition",       limit: 191
    t.string   "simple_name",   limit: 191
    t.boolean  "name_flagged",              default: false
  end

  create_table "adset_actions", force: :cascade do |t|
    t.string   "action_type", limit: 191
    t.float    "value",       limit: 24
    t.string   "account_id",  limit: 191
    t.string   "campaign_id", limit: 191
    t.string   "adset_id",    limit: 191
    t.string   "adset_name",  limit: 191
    t.string   "objective",   limit: 191
    t.string   "audience",    limit: 191
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "adset_insights", force: :cascade do |t|
    t.string   "adset_name",  limit: 191
    t.float    "spend",       limit: 24
    t.float    "frequency",   limit: 24
    t.string   "adset_id",    limit: 191
    t.string   "account_id",  limit: 191
    t.string   "campaign_id", limit: 191
    t.string   "objective",   limit: 191
    t.string   "audience",    limit: 191
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "impressions", limit: 191
  end

  create_table "adset_targetings", force: :cascade do |t|
    t.string   "age_min",     limit: 191
    t.string   "age_max",     limit: 191
    t.string   "account_id",  limit: 191
    t.string   "campaign_id", limit: 191
    t.string   "adset_id",    limit: 191
    t.string   "audience",    limit: 191
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "targeting",   limit: 191
    t.string   "interests",   limit: 191
    t.string   "cities",      limit: 191
  end

  create_table "adsets", force: :cascade do |t|
    t.string   "name",         limit: 191
    t.string   "adset_id",     limit: 191
    t.string   "account_id",   limit: 191
    t.string   "campaign_id",  limit: 191
    t.string   "status",       limit: 191
    t.float    "daily_budget", limit: 24
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "audience",     limit: 191
    t.string   "targeting",    limit: 191
    t.string   "objective",    limit: 191
    t.boolean  "name_flagged",             default: false
  end

  create_table "authentications", force: :cascade do |t|
    t.string   "facebook_access_token",        limit: 191
    t.string   "facebook_name",                limit: 191
    t.string   "user_id",                      limit: 191
    t.string   "facebook_user_id",             limit: 191
    t.string   "facebook_profile_picture_url", limit: 191
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  create_table "campaign_actions", force: :cascade do |t|
    t.string   "action_type",   limit: 191
    t.string   "account_id",    limit: 191
    t.float    "value",         limit: 24
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "campaign_id",   limit: 191
    t.string   "objective",     limit: 191
    t.string   "campaign_name", limit: 191
    t.string   "audience",      limit: 191
    t.float    "spend",         limit: 24
    t.string   "impressions",   limit: 191
  end

  create_table "campaign_insight_twos", force: :cascade do |t|
    t.string   "campaign_name", limit: 191
    t.integer  "impressions",   limit: 4
    t.float    "spend",         limit: 24
    t.float    "cpm",           limit: 24
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "audience",      limit: 4
    t.string   "campaign_id",   limit: 191
    t.string   "account_id",    limit: 191
    t.string   "objective",     limit: 191
  end

  create_table "campaign_insights", force: :cascade do |t|
    t.string   "account_id",     limit: 191
    t.string   "campaign_id",    limit: 191
    t.integer  "website_clicks", limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "objective",      limit: 191
    t.string   "campaign_name",  limit: 191
    t.string   "audience",       limit: 191
    t.float    "spend",          limit: 24
    t.string   "impressions",    limit: 191
  end

  create_table "campaigns", force: :cascade do |t|
    t.string   "account_id",    limit: 191
    t.datetime "created_time"
    t.string   "objective",     limit: 191
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "campaign_id",   limit: 191
    t.string   "placement",     limit: 191
    t.integer  "spend",         limit: 4
    t.float    "frequency",     limit: 24
    t.string   "impressions",   limit: 191
    t.float    "cpm",           limit: 24
    t.integer  "reach",         limit: 4
    t.string   "audience",      limit: 191
    t.datetime "date_start"
    t.datetime "date_stop"
    t.string   "campaign_name", limit: 191
    t.boolean  "name_flagged",              default: false
    t.boolean  "post",                      default: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 191, default: "", null: false
    t.string   "encrypted_password",     limit: 191, default: "", null: false
    t.string   "reset_password_token",   limit: 191
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 191
    t.string   "last_sign_in_ip",        limit: 191
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "provider",               limit: 191
    t.string   "uid",                    limit: 191
    t.string   "oauth_token",            limit: 191
    t.datetime "oauth_expires_at"
    t.string   "confirmation_token",     limit: 128
    t.string   "remember_token",         limit: 128
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
