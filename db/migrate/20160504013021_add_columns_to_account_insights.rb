class AddColumnsToAccountInsights < ActiveRecord::Migration
  def change
    add_column :account_insights, :actions, :string
    add_column :account_insights, :impressions, :string
    add_column :account_insights, :spend, :float
    add_column :account_insights, :website_clicks, :integer

    remove_column :account_insights, :total_actions
  end
end
