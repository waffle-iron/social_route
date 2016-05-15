class ChangeMinMaxAgeToStringForAdsetTargeting < ActiveRecord::Migration
  def change
    change_column :adset_targetings, :age_min, :string
    change_column :adset_targetings, :age_max, :string
  end
end
