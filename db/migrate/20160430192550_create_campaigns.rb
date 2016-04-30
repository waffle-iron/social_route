class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string   :account_id
      t.string   :configured_status
      t.datetime :created_time
      t.string   :effective_status
      t.string   :name
      t.string   :objective
      t.datetime :start_time
      t.string   :status
      t.datetime :stop_time
      t.datetime :updated_time

      t.timestamps null: false
    end
  end
end
