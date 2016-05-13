class AddAudienceToAdset < ActiveRecord::Migration
  def change
    add_column :adsets, :audience, :string
  end
end
