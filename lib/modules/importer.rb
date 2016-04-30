module Importer
  require 'rest-client'

  BASE_URL = 'https://graph.facebook.com/v2.6/'
  ACCESS_TOKEN = 'EAANNAsbKK4kBAAQZBCIARpqy3FWuid4QMq851PDNfvOcgKPGFfqLJpbsMrZCXqFBOd47rnzGaZAnIhRzQnhQSK1lHO68MAg2khAPZBmlUYsHRjiZBPq0XwNabHF35bRllNZAZBQU5EZAQXZBXQlQBrquv4JVcwOZCmndWfNZBtyFcflgQZDZD'

  def self.import
    puts "Start Import Rake Task \n"
    puts "--------------------------------------------------------------------"
    puts "|                       Wipe Current Database                      |"
    puts "--------------------------------------------------------------------"

    # Account.delete_all
    Campaign.delete_all

    puts "--------------------------------------------------------------------"
    puts "|                     Generate ACCOUNT DATA                         |"
    puts "--------------------------------------------------------------------"

    # build_accounts
    build_campagins

    puts "Import Rake Task has been sucessfully executed. \n\n"
  end

  def self.build_accounts
    account_columns = ['name', 'account_status', 'age', 'amount_spent']

    http_response = RestClient.get "#{BASE_URL}/me/adaccounts", {:params => {:access_token => ACCESS_TOKEN, 'fields' => account_columns}}
    raw_data = JSON.parse(http_response)['data'].sort_by{|x| x[:name]}.reverse

    raw_data.each do |account|
      Account.create(
        account_id:     account['id'],
        account_status: account['account_status'],
        age:            account['age'],
        amount_spent:   account['amount_spent'],
        name:           account['name']
      )
    end

    # Output Account Data
    Account.all.each do |account|
      puts account.attributes
    end
  end

  def self.build_campagins
    account_ids = Account.pluck('account_id')
    campaign_columns = ['account_id', 'configured_status', 'created_time',
                        'effective_status', 'name', 'objective', 'start_time',
                        'status', 'stop_time', 'updated_time']

    ['act_1219093434772270'].each do |account_id|
      http_response = RestClient.get "#{BASE_URL}/#{account_id}/campaigns", {:params => {:access_token => ACCESS_TOKEN, 'fields' => campaign_columns}}
      raw_data = JSON.parse(http_response)['data'].sort_by{|x| x[:name]}.reverse

      raw_data.each do |campaign|
        Campaign.create(
          campaign_id: campaign['id'],
          account_id:  campaign['account_id'],
          configured_status: campaign['configured_status'],
          created_time: campaign['created_time'],
          effective_status: campaign['effective_status'],
          name: campaign['name'],
          objective: campaign['objective'],
          start_time: campaign['start_time'],
          status: campaign['status'],
          stop_time: campaign['stop_time'],
          updated_time: campaign['updated_time']
        )
      end

      # Output Campaign Data
      Campaign.all.each do |campaign|
        puts campaign.attributes
      end
    end
  end
end
