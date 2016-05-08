class AddImpressionsAndSpendToCampaignInsights < ActiveRecord::Migration
  def change
    add_column :campaign_insights, :spend, :float
    add_column :campaign_insights, :impressions, :string
  end
end

