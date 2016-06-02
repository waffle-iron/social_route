class AddFieldsToCampaign < ActiveRecord::Migration
  def change
    remove_column :campaigns, :effective_status
    remove_column :campaigns, :name
    remove_column :campaigns, :start_time
    remove_column :campaigns, :stop_time
    remove_column :campaigns, :cpc
    remove_column :campaigns, :cpp
    remove_column :campaigns, :total_actions
    add_column    :campaigns, :date_start, :datetime
    add_column    :campaigns, :date_stop, :datetime
    add_column    :campaigns, :campaign_name, :string
  end
end
