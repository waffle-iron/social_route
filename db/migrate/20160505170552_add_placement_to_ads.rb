class AddPlacementToAds < ActiveRecord::Migration
  def change
    add_column :ads, :placement, :string
  end
end
