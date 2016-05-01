module Importer
  require 'rest-client'

  BASE_URL = 'https://graph.facebook.com/v2.6/'
  ACCESS_TOKEN = 'EAANNAsbKK4kBAE9WMgu19Ej7AmlpzZA06xfGW1IKrVikGYx6BwMjQj1r9ZBkQA6asFY9ms0yXQZCa8uS306tQiTUwrEM0BWOXzxFFZAjKhu09T9JjnDdmScZAjasJpSD5LMzeMY0Kpf24XAefJxmoszOgWqY162nmOAFu0DcZBmwZDZD'


  def self.import
    puts "Start Import Rake Task \n"
    puts "--------------------------------------------------------------------"
    puts "|                       Wipe Current Database                      |"
    puts "--------------------------------------------------------------------"

    # Account.delete_all
    Campaign.delete_all
    # Ad.delete_all

    puts "--------------------------------------------------------------------"
    puts "|                     Generate ACCOUNT DATA                         |"
    puts "--------------------------------------------------------------------"

    # build_accounts
    build_campagins
    # build_ads

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
    campaign_ids = JSON.parse(RestClient.get "#{BASE_URL}/act_1219093434772270/campaigns", {:params => {:access_token => ACCESS_TOKEN}})['data']

    campaign_columns = ['date_start','date_stop','account_id','ad_id',
                        'campaign_id', 'campaign_name', 'objective',
                        'total_actions','impressions','spend','frequency',
                        'reach','cpc','cpm','cpp']

    campaign_ids.each do |campaign_id|
      http_response = RestClient.get "#{BASE_URL}/#{campaign_id['id']}/insights", {:params => {'access_token' => ACCESS_TOKEN, 'fields' => campaign_columns, 'breakdowns' => 'placement'}}
      raw_data = JSON.parse(http_response)['data']

      raw_data.each do |campaign|
        Campaign.create(
          campaign_id:   campaign_id['id'],
          account_id:    campaign['account_id'],
          name:          campaign['campaign_name'],
          objective:     campaign['objective'],
          start_time:    campaign['date_start'],
          stop_time:     campaign['date_stop'],
          placement:     campaign['placement'],
          spend:         campaign['spend'],
          frequency:     campaign['frequency'],
          impressions:   campaign['impressions'],
          cpc:           campaign['cpc'],
          cpm:           campaign['cpm'],
          cpp:           campaign['cpp'],
          reach:         campaign['reach'],
          total_actions: campaign['total_actions']
        )
      end

      # Output Campaign Data
      Campaign.all.each do |campaign|
        puts campaign.attributes
      end
    end
  end

  def self.build_ads
    account_ids = Account.pluck('account_id')
    ad_columns = ['date_start', 'date_stop', 'account_id', 'ad_id', 'ad_name',
                  'campaign_id', 'adset_id', 'objective', 'total_actions',
                  'impressions', 'spend', 'frequency', 'reach', 'cpm']

    ad_ids = JSON.parse(RestClient.get "#{BASE_URL}/act_1219093434772270/ads", {:params => {:access_token => ACCESS_TOKEN}})['data']

    ad_ids.each do |ad_id|
      http_response = RestClient.get "#{BASE_URL}/#{ad_id['id']}/insights", {:params => {:access_token => ACCESS_TOKEN, 'fields' => ad_columns, :date_preset => 'lifetime'}}
      raw_data = JSON.parse(http_response)['data'].sort_by{|x| x[:name]}.reverse

      raw_data.each do |ad|
        Ad.create(
          date_start: ad['date_start'],
          date_stop: ad['date_stop'],
          account_id: ad['account_id'],
          ad_id: ad['ad_id'],
          ad_name: ad['ad_name'],
          campaign_id: ad['campaign_id'],
          adset_id: ad['adset_id'],
          objective: ad['objective'],
          total_actions: ad['total_actions'],
          impressions: ad['impressions'],
          spend: ad['spend'],
          frequency: ad['frequency'],
          reach: ad['reach'],
          cpm: ad['cpm']
        )
      end

      # Output Campaign Data
      Ad.all.each do |ad|
        puts ad.attributes
      end
    end
  end
end
