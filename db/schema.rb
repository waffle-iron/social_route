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

ActiveRecord::Schema.define(version: 20160602213327) do

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

  create_table "account_placements", force: :cascade do |t|
    t.string   "date_start"
    t.string   "date_stop"
    t.string   "account_id"
    t.integer  "impressions"
    t.float    "spend"
    t.string   "placement"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
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
    t.string   "format"
    t.string   "edition"
    t.string   "simple_name"
  end

  create_table "adset_actions", force: :cascade do |t|
    t.string   "action_type"
    t.float    "value"
    t.string   "account_id"
    t.string   "campaign_id"
    t.string   "adset_id"
    t.string   "adset_name"
    t.string   "objective"
    t.string   "audience"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "adset_insights", force: :cascade do |t|
    t.string   "adset_name"
    t.float    "spend"
    t.float    "frequency"
    t.string   "adset_id"
    t.string   "account_id"
    t.string   "campaign_id"
    t.string   "objective"
    t.string   "audience"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "impressions"
  end

  create_table "adset_targetings", force: :cascade do |t|
    t.string   "age_min"
    t.string   "age_max"
    t.string   "account_id"
    t.string   "campaign_id"
    t.string   "adset_id"
    t.string   "audience"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "targeting"
    t.string   "interests"
    t.string   "cities"
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
    t.string   "targeting"
    t.string   "objective"
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

  create_table "campaign_insight_twos", force: :cascade do |t|
    t.string   "campaign_name"
    t.integer  "impressions"
    t.float    "spend"
    t.float    "cpm"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "audience"
    t.string   "campaign_id"
    t.string   "account_id"
    t.string   "objective"
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
    t.string   "objective"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "campaign_id"
    t.string   "placement"
    t.integer  "spend"
    t.float    "frequency"
    t.string   "impressions"
    t.float    "cpm"
    t.integer  "reach"
    t.string   "audience"
    t.datetime "date_start"
    t.datetime "date_stop"
    t.string   "campaign_name"
  end

end
