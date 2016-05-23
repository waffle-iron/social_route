class ChangeAudiencesToIntegers < ActiveRecord::Migration
  def change
    change_column :ad_actions, :audience, :interger
    change_column :ads, :audience, :interger
    change_column :adset_actions, :audience, :interger
    change_column :adset_insights, :audience, :interger
    change_column :adset_targetings, :audience, :interger
    change_column :adsets, :audience, :interger
    change_column :campaign_actions, :audience, :interger
    change_column :campaign_insights, :audience, :interger
  end
end

