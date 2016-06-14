class CreateAd2PlacementActions < ActiveRecord::Migration
  def change
    create_table :ad2_placement_actions do |t|
      t.string   "account_id",  limit: 191
      t.string   "action_type", limit: 191
      t.float    "value",       limit: 24
      t.datetime "created_at",              null: false
      t.datetime "updated_at",              null: false
      t.string   "objective",   limit: 191
      t.string :placement
      t.timestamps null: false
    end
  end
end
