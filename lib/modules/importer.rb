module Importer
  require 'rest-client'

  BASE_URL = 'https://graph.facebook.com/v2.6/'
  ACCESS_TOKEN = 'EAANNAsbKK4kBAJqoqtU3v3eZBc4ozid7MlOCYQDkq2RInHT4ff8qFXZBuSTdPMFqKFHq2I4ZBAsA50eamFI81UbsKwt8joKZBCReFcCrfr2E6gOO2Ee4UorHZCDqxfePAV4Dc2fwwgDtYzSOir8b0VCTmdCAZCWCYZCA7rvTB8opgZDZD'

  def self.import
    puts "Start Import Rake Task \n"
    puts "--------------------------------------------------------------------"
    puts "|                     Generate ACCOUNT DATA                         |"
    puts "--------------------------------------------------------------------"

    # build_accounts
    # build_account_insights
    # build_campagins
    build_ads

    puts "Import Rake Task has been sucessfully executed. \n\n"
  end

  def self.build_accounts
    Account.delete_all
    account_columns = ['name', 'account_status', 'amount_spent']

    http_response = RestClient.get "#{BASE_URL}/me/adaccounts", {:params => {:access_token => ACCESS_TOKEN, 'fields' => account_columns}}
    raw_data = JSON.parse(http_response)['data'].sort_by{|x| x[:name]}.reverse

    raw_data.each do |account|
      Account.create(
        account_id:     account['id'],
        account_status: account['account_status'],
        amount_spent:   account['amount_spent'],
        name:           account['name']
      )
    end

    # Output Account Data
    Account.all.each do |account|
      puts account.attributes
    end
  end

  def self.build_account_insights
    AccountInsight.delete_all
    Action.delete_all
    account_ids = Account.pluck('account_id')

    # General Breakdown
    ['act_1219093434772270'].each do |account_id|
      http_response = RestClient.get "#{BASE_URL}/#{account_id}/insights",
                                     {:params => {'access_token' => ACCESS_TOKEN,
                                                  'date_preset' => 'lifetime',
                                                  'breakdowns' => ['age', 'gender'],
                                                  'time_increment' => 1,
                                                  'limit' => 365,
                                                  'fields' => ['account_name','impressions','spend','website_clicks','actions']
                                                  }}
      raw_data = JSON.parse(http_response)['data']

      raw_data.each do |account_insight|
        AccountInsight.create(
          account_id:    account_id,
          account_name:  account_insight['account_name'],
          impressions:   account_insight['impressions'],
          spend:   account_insight['spend'],
          website_clicks:   account_insight['website_clicks'],
          age: account_insight['age'],
          gender: account_insight['gender'],
          date: account_insight['date_start']
        )

        account_insight['actions'].each do |action|
          Action.create(
            action_type: action['action_type'],
            value: action['value'],
            date: account_insight['date_start'],
            account_id: account_id
          )
        end
      end
    end

    # Age Breakdown
    # ['act_1219093434772270'].each do |account_id|
    #   http_response = RestClient.get "#{BASE_URL}/#{account_id}/insights", {:params => {'access_token' => ACCESS_TOKEN, 'fields' => ['total_actions','account_name'], 'breakdowns' => 'age'}}
    #   raw_data = JSON.parse(http_response)['data']
    #
    #   raw_data.each do |account_insight|
    #     AccountInsight.create(
    #       account_id:    account_id,
    #       account_name:  account_insight['account_name'],
    #       age:           account_insight['age'],
    #       total_actions: account_insight['total_actions']
    #     )
    #   end
    # end

    # Gender Breakdown
    # ['act_1219093434772270'].each do |account_id|
    #   http_response = RestClient.get "#{BASE_URL}/#{account_id}/insights", {:params => {'access_token' => ACCESS_TOKEN, 'fields' => ['total_actions','account_name'], 'breakdowns' => 'gender'}}
    #   raw_data = JSON.parse(http_response)['data']
    #
    #   raw_data.each do |account_insight|
    #     AccountInsight.create(
    #       account_id:    account_id,
    #       account_name:  account_insight['account_name'],
    #       gender:        account_insight['gender'],
    #       total_actions: account_insight['total_actions']
    #     )
    #   end
    # end

    # Output Age Breakdown Account Insight Data
    # AccountInsight.all.each do |account_insight|
    #   puts account_insight.attributes
    # end
  end

  def self.build_campagins
    Campaign.delete_all

    campaign_ids = JSON.parse(RestClient.get "#{BASE_URL}/act_1219093434772270/campaigns", {:params => {:access_token => ACCESS_TOKEN, 'date_preset' => 'lifetime'}})['data']

    campaign_columns = ['date_start','date_stop','account_id','ad_id',
                        'campaign_id', 'campaign_name', 'objective',
                        'total_actions','impressions','spend','frequency',
                        'reach','cpc','cpm','cpp']

    campaign_ids.each do |campaign_id|
      http_response = RestClient.get "#{BASE_URL}/#{campaign_id['id']}/insights", {:params => {'access_token' => ACCESS_TOKEN, 'date_preset' => 'lifetime', 'fields' => campaign_columns, 'breakdowns' => 'placement'}}
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
    Ad.delete_all

    account_ids = Account.pluck('account_id')
    ad_columns = ['account_id', 'ad_id', 'ad_name',
                  'campaign_id', 'adset_id', 'objective',
                  'impressions', 'spend', 'frequency', 'reach']

    ad_ids = JSON.parse(RestClient.get "#{BASE_URL}/act_1219093434772270/ads", {:params => {:access_token => ACCESS_TOKEN, 'date_preset' => 'lifetime'}})['data']

    ad_ids.each do |ad_id|
      http_response = RestClient.get "#{BASE_URL}/#{ad_id['id']}/insights", {:params => {:access_token => ACCESS_TOKEN, 'fields' => ad_columns, :date_preset => 'lifetime', :breakdowns => 'placement'}}
      raw_data = JSON.parse(http_response)['data'].sort_by{|x| x[:name]}.reverse

      raw_data.each do |ad|
        Ad.create(
          account_id: ad['account_id'],
          ad_id: ad['ad_id'],
          ad_name: ad['ad_name'],
          campaign_id: ad['campaign_id'],
          adset_id: ad['adset_id'],
          objective: ad['objective'],
          impressions: ad['impressions'],
          spend: ad['spend'],
          frequency: ad['frequency'],
          reach: ad['reach'],
          placement: ad['placement']
        )
      end

      # Output Campaign Data
      Ad.all.each do |ad|
        puts ad.attributes
      end
    end
  end
end
