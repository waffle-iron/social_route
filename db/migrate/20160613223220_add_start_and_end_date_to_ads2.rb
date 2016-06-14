class AddStartAndEndDateToAds2 < ActiveRecord::Migration
  def change
    add_column :ad2s, :date_start, :string
    add_column :ad2s, :date_stop, :string
  end
end
