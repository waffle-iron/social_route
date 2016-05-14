class ChangeAdsetInsightNameToAdsetName < ActiveRecord::Migration
  def change
    rename_column :adset_insights, :name, :adset_name
  end
end
