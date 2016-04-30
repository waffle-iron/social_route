class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :account_id
      t.string :account_status
      t.float :age
      t.string :amount_spent
      t.string :name
      t.timestamps null: false
    end
  end
end
