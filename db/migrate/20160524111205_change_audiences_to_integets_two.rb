class ChangeAudiencesToIntegetsTwo < ActiveRecord::Migration
  def change
    change_column :ad_actions, :audience, :integer
    change_column :ads, :audience, :integer
    change_column :adset_actions, :audience, :integer
    change_column :adset_insights, :audience, :integer
    change_column :adset_targetings, :audience, :integer
    change_column :adsets, :audience, :integer
    change_column :campaign_actions, :audience, :integer
    change_column :campaign_insights, :audience, :integer
  end
end
