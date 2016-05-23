class ChangeAudienceInCampaignInsightsTwo < ActiveRecord::Migration
  def change
    change_column :campaign_insight_twos, :audience, :interger
  end
end
