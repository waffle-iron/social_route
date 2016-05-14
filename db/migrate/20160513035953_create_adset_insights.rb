class CreateAdsetInsights < ActiveRecord::Migration
  def change
    create_table :adset_insights do |t|
      t.string :name
      t.float :spend
      t.float :frequency
      t.string :adset_id
      t.string :account_id
      t.string :campaign_id
      t.string :adset_name
      t.string :objective
      t.string :audience

      t.timestamps null: false
    end
  end
end
