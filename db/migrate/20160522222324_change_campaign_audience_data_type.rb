class ChangeCampaignAudienceDataType < ActiveRecord::Migration
  def change
     change_column :campaigns, :audience, :interger
  end
end
