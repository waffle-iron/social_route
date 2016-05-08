class AddSpendAndImpressionsToCampaignInsights < ActiveRecord::Migration
  def change
    add_column :campaign_actions, :spend, :float
    add_column :campaign_actions, :impressions, :string
  end
end

