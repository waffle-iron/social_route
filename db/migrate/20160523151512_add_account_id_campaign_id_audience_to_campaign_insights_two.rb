class AddAccountIdCampaignIdAudienceToCampaignInsightsTwo < ActiveRecord::Migration
  def change
    add_column :campaign_insight_twos, :audience, :string
    add_column :campaign_insight_twos, :campaign_id, :string
    add_column :campaign_insight_twos, :account_id, :string
  end
end
