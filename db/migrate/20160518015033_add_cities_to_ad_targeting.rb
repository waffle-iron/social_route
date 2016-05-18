class AddCitiesToAdTargeting < ActiveRecord::Migration
  def change
    add_column :adset_targetings, :cities, :string
  end
end
