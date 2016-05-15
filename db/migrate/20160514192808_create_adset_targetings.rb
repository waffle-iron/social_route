class CreateAdsetTargetings < ActiveRecord::Migration
  def change
    create_table :adset_targetings do |t|
      t.integer :age_min
      t.integer :age_max
      t.string  :account_id
      t.string  :campaign_id
      t.string  :adset_id
      t.string  :audience
      t.timestamps null: false
    end
  end
end
