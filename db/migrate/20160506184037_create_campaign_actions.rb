class CreateCampaignActions < ActiveRecord::Migration
  def change
    create_table :campaign_actions do |t|
      t.string :action_type
      t.string :account_id
      t.float :value
      t.timestamps null: false
    end
  end
end
