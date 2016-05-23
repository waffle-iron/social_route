class CreateCampaignInsightTwos < ActiveRecord::Migration
  def change
    create_table :campaign_insight_twos do |t|
      t.string :campaign_name
      t.integer :impressions
      t.float :spend
      t.float :cpm

      t.timestamps null: false
    end
  end
end
