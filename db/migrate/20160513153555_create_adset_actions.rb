class CreateAdsetActions < ActiveRecord::Migration
  def change
    create_table :adset_actions do |t|
      t.string   "action_type"
      t.float    "value"
      t.string   "account_id"
      t.string   "campaign_id"
      t.string   "adset_id"
      t.string   "adset_name"
      t.string   "objective"
      t.string   "audience"

      t.timestamps null: false
    end
  end
end
