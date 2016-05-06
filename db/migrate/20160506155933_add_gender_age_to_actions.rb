class AddGenderAgeToActions < ActiveRecord::Migration
  def change
    add_column :actions, :age, :string
    add_column :actions, :gender, :string
  end
end
