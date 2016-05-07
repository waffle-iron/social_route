class AddCampaignNameAndCampaignObjectiveToCampaignActions < ActiveRecord::Migration
  def change
    add_column :campaign_actions, :objective, :string
    add_column :campaign_actions, :campaign_name, :string
  end
end
