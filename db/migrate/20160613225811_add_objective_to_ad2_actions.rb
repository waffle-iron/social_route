class AddObjectiveToAd2Actions < ActiveRecord::Migration
  def change
    add_column :ad2_actions, :objective, :string
  end
end
