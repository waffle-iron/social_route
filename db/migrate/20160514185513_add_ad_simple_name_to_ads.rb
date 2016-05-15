class AddAdSimpleNameToAds < ActiveRecord::Migration
  def change
    add_column :ads, :simple_name, :string
  end
end
