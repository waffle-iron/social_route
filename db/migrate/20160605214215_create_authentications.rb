class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.string :facebook_access_token
      t.string :facebook_name
      t.string :user_id
      t.string :facebook_user_id
      t.string :facebook_profile_picture_url

      t.timestamps null: false
    end
  end
end
