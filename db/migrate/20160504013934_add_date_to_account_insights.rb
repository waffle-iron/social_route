class AddDateToAccountInsights < ActiveRecord::Migration
  def change
    add_column :account_insights, :date, :string
  end
end
