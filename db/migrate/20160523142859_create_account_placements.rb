class CreateAccountPlacements < ActiveRecord::Migration
  def change
    create_table :account_placements do |t|
      t.string :date_start
      t.string :date_stop
      t.string :account_id
      t.integer :impressions
      t.float :spend
      t.string :placement
      t.timestamps null: false
    end
  end
end
