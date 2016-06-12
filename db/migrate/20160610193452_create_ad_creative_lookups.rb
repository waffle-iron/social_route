class CreateAdCreativeLookups < ActiveRecord::Migration
  def change
    create_table :ad_creative_lookups do |t|
      t.string :ad_id
      t.string :creative_id
      t.timestamps null: false
    end
  end
end
