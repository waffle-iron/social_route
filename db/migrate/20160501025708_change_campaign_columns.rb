class ChangeCampaignColumns < ActiveRecord::Migration
  def change
    add_column :campaigns, :placement, :string
    add_column :campaigns, :spend, :integer
    add_column :campaigns, :frequency, :float
    add_column :campaigns, :impressions, :string
    add_column :campaigns, :cpc, :float
    add_column :campaigns, :cpm, :float
    add_column :campaigns, :cpp, :float
    add_column :campaigns, :reach, :integer
    add_column :campaigns, :total_actions, :integer

    remove_column :campaigns, :configured_status
    remove_column :campaigns, :status
    remove_column :campaigns, :updated_time
  end
end
