class AddAudienceToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :audience, :string
  end
end
