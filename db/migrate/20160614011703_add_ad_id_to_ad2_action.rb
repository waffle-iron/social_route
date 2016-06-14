class AddAdIdToAd2Action < ActiveRecord::Migration
  def change
    add_column :ad2_actions, :ad_id, :string
  end
end
