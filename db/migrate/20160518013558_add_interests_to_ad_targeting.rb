class AddInterestsToAdTargeting < ActiveRecord::Migration
  def change
    add_column :adset_targetings, :targeting, :string
  end
end
