class AddTargetingToAdsets < ActiveRecord::Migration
  def change
    add_column :adsets, :targeting, :string
  end
end
