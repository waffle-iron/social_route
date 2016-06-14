class DropAccountInsightsTable < ActiveRecord::Migration
  def change
    drop_table :account_insights
  end
end
