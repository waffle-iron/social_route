class AddFormatAndEditionToAds < ActiveRecord::Migration
  def change
    add_column :ads, :format, :string
    add_column :ads, :edition, :string
  end
end
