class AddCampaignIdToCampaignAction < ActiveRecord::Migration
  def change
    add_column :campaign_actions, :campaign_id, :string
  end
end
