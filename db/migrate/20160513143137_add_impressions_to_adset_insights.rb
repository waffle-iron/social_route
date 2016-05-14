class AddImpressionsToAdsetInsights < ActiveRecord::Migration
  def change
    add_column :adset_insights, :impressions, :string
  end
end
