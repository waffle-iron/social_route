class CreateAdsetInsights < ActiveRecord::Migration
  def change
    create_table :adset_insights do |t|



      t.timestamps null: false
    end
  end
end
