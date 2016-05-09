class AddAudienceToAds < ActiveRecord::Migration
  def change
    add_column :ads, :audience, :string
  end
end
