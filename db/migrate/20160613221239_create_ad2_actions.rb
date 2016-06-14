class CreateAd2Actions < ActiveRecord::Migration
  def change
    create_table :ad2_actions do |t|
      t.string :account_id
      t.string :action_type
      t.float :value
      t.timestamps null: false
    end
  end
end
