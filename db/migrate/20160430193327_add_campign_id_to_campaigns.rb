class AddCampignIdToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :campaign_id, :string
  end
end
