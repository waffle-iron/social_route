class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.string :account_id
      t.string :action_type
      t.string :date
      t.float :value

      t.timestamps null: false
    end
  end
end
