class CreateCampaignInsights < ActiveRecord::Migration
  def change
    create_table :campaign_insights do |t|
      t.string :account_id
      t.string :campaign_id
      t.integer :website_clicks
      t.timestamps null: false
    end
  end
end
