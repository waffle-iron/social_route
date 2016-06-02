class ChangeAudienceBackToString < ActiveRecord::Migration
  def change
    change_column :ad_actions, :audience, :string
    change_column :ads, :audience, :string
    change_column :adset_actions, :audience, :string
    change_column :adset_insights, :audience, :string
    change_column :adset_targetings, :audience, :string
    change_column :adsets, :audience, :string
    change_column :campaign_actions, :audience, :string
    change_column :campaign_insights, :audience, :string
  end
end
