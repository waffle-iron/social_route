class ChangeImageUrlsToText < ActiveRecord::Migration
  def change
    change_column :ad_account_creatives, :image_url, :text
    change_column :ad_account_creatives, :thumbnail_url, :text
  end
end
