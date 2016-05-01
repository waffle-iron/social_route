class CreateAds < ActiveRecord::Migration
  def change
    create_table :ads do |t|
      t.string :date_start
      t.string :date_stop
      t.string :account_id
      t.string :ad_id
      t.string :ad_name
      t.string :campaign_id
      t.string :adset_id
      t.string :objective
      t.integer :total_actions
      t.string :impressions
      t.float :spend
      t.float :frequency
      t.integer :reach
      t.float :cpm

      t.timestamps null: false
    end
  end
end
