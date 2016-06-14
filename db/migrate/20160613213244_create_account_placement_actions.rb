class CreateAccountPlacementActions < ActiveRecord::Migration
  def change
    create_table :account_placement_actions do |t|
      t.string :account_id
      t.string :action_type
      t.float :value
      t.string :placement
      t.timestamps null: false
    end
  end
end
