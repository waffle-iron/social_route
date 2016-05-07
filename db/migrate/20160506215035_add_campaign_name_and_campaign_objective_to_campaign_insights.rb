class AddCampaignNameAndCampaignObjectiveToCampaignInsights < ActiveRecord::Migration
  def change
    add_column :campaign_insights, :objective, :string
    add_column :campaign_insights, :campaign_name, :string
  end
end
