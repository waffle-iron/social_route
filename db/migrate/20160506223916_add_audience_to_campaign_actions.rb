class AddAudienceToCampaignActions < ActiveRecord::Migration
  def change
    add_column :campaign_actions, :audience, :string
  end
end
