class CreateAdAccountCreatives < ActiveRecord::Migration
  def change
    create_table :ad_account_creatives do |t|
      t.string :image_url
      t.string :thumbnail_url
      t.string :creative_id
      t.timestamps null: false
    end
  end
end
