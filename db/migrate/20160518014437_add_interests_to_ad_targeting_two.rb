class AddInterestsToAdTargetingTwo < ActiveRecord::Migration
  def change
    add_column :adset_targetings, :interests, :string
  end
end
