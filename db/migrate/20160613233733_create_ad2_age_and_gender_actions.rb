class CreateAd2AgeAndGenderActions < ActiveRecord::Migration
  def change
    create_table :ad2_age_and_gender_actions do |t|
      t.string   "account_id",  limit: 191
      t.string   "action_type", limit: 191
      t.float    "value",       limit: 24
      t.datetime "created_at",              null: false
      t.datetime "updated_at",              null: false
      t.string   "objective",   limit: 191
      t.string :age
      t.string :gender
      t.timestamps null: false
    end
  end
end
