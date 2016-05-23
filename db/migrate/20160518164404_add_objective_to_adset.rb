class AddObjectiveToAdset < ActiveRecord::Migration
  def change
    add_column :adsets, :objective, :string
  end
end
