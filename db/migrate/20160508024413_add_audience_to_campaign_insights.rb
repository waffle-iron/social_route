class AddAudienceToCampaignInsights < ActiveRecord::Migration
  def change
    add_column :campaign_insights, :audience, :string
  end
end
