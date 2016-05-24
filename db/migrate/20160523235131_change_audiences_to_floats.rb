class ChangeAudiencesToFloats < ActiveRecord::Migration
  def change
    change_column :ad_actions, :audience, :float
    change_column :ads, :audience, :float
    change_column :adset_actions, :audience, :float
    change_column :adset_insights, :audience, :float
    change_column :adset_targetings, :audience, :float
    change_column :adsets, :audience, :float
    change_column :campaign_actions, :audience, :float
    change_column :campaign_insights, :audience, :float
  end
end
