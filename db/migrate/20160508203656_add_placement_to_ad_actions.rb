class AddPlacementToAdActions < ActiveRecord::Migration
  def change
    add_column :ad_actions, :placement, :string
  end
end
