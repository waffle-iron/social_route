class CreateAccountInsights < ActiveRecord::Migration
  def change
    create_table :account_insights do |t|
      t.string :account_id
      t.string :account_name
      t.string :age
      t.string :gender
      t.integer :total_actions

      t.timestamps null: false
    end
  end
end
