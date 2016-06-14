class AddFormatEditionSimpleNameToAd2 < ActiveRecord::Migration
  def change
    add_column :ad2s, :format, :string
    add_column :ad2s, :edition, :string
    add_column :ad2s, :simple_name, :string
    add_column :ad2_actions, :format, :string
    add_column :ad2_actions, :edition, :string
    add_column :ad2_actions, :simple_name, :string
  end
end
