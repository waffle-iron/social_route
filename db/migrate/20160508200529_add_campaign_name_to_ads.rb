class AddCampaignNameToAds < ActiveRecord::Migration
  def change
    add_column :ads, :campaign_name, :string
  end
end
