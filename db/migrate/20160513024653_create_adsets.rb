class CreateAdsets < ActiveRecord::Migration
  def change
    create_table :adsets do |t|
      t.string :name
      t.string :adset_id
      t.string :account_id
      t.string :campaign_id
      t.string :status
      t.float :daily_budget

      t.timestamps null: false
    end
  end
end
