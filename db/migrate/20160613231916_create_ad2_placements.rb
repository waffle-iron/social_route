class CreateAd2Placements < ActiveRecord::Migration
  def change
    create_table :ad2_placements do |t|
      t.string   :account_id
      t.string   :campaign_id
      t.string   :adset_id
      t.string   :ad_id
      t.string   :ad_name
      t.string   :objective
      t.string   :placement
      t.string   :impressions
      t.float    :spend
      t.float    :frequency
      t.integer  :reach
      t.timestamps null: false
    end
  end
end
