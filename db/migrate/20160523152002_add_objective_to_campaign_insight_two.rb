class AddObjectiveToCampaignInsightTwo < ActiveRecord::Migration
  def change
    add_column :campaign_insight_twos, :objective, :string
  end
end
