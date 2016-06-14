class AddAudienceToAd2AndAd2Action < ActiveRecord::Migration
  def change
    add_column :ad2s, :audience, :string
    add_column :ad2_actions, :audience, :string
  end
end
