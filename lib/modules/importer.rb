module Importer
  require 'rest-client'

  BASE_URL = 'https://graph.facebook.com/v2.6/'
  ACCESS_TOKEN = 'EAANNAsbKK4kBAHkYaq54guCrurvvsc9FawhGqs8QAKZCyIQfitMsvxL7973T36FlIqjdQHC6ZCvWpvbXOSdgD2SaaOnq3qvrWHVyreULBgnQWGOd4YeEEVn8DLSxl7d8sDjDO10ndac6RNohfK1UyCcndbvCslwgmMskialAZDZD'

  def self.import
    puts "Start Import Rake Task \n"
    puts "--------------------------------------------------------------------"
    puts "|                     Generate Account Data                        |"
    puts "--------------------------------------------------------------------"

    puts "\nBuilding Account Data \n"
    # build_accounts
    puts "Done \n"

    puts "\nBuilding Account Insight Data \n"
    # build_account_insights
    puts "Done \n\n"

    puts "--------------------------------------------------------------------"
    puts "|                     Generate Campaign Data                       |"
    puts "--------------------------------------------------------------------"

    puts "\nBuilding Campaign Data \n"
    # build_campaigns
    puts "Done \n"

    puts "\nBuilding Campaign Insight Data \n"
    # build_campaigns_insights
    puts "Done \n\n"

    puts "--------------------------------------------------------------------"
    puts "|                     Generate Ad Data                             |"
    puts "--------------------------------------------------------------------"

    puts "\nBuilding Ads Data \n"
    build_ads
    puts "Done \n"

    puts "Import sucessfull \n\n"
  end

  def self.build_accounts
    Account.delete_all

    account_columns = ['name', 'account_status', 'amount_spent']

    http_response = RestClient.get "#{BASE_URL}/me/adaccounts",
                                   {:params => {'access_token' => ACCESS_TOKEN,
                                                'fields' => account_columns}}
    raw_data = JSON.parse(http_response)['data']

    raw_data.each do |account|
      Account.create(
        account_id:     account['id'],
        account_status: account['account_status'],
        amount_spent:   account['amount_spent'],
        name:           account['name']
      )
    end

    # Set Account IDs
    # account_ids

    # Output Account Data
    puts "Accounts Created: #{Account.count}"
  end

  def self.build_account_insights
    AccountInsight.delete_all
    Action.delete_all

    account_ids.each do |account_id|
      # General Breakdown
      account_insight_columns = ['impressions','spend','actions']

      http_response = RestClient.get "#{BASE_URL}/#{account_id}/insights",
                                     {:params => {'access_token' => ACCESS_TOKEN,
                                                  'date_preset' => 'lifetime',
                                                  'time_increment' => 1,
                                                  'limit' => 1000,
                                                  'fields' => account_insight_columns
                                                  }}

      raw_data = JSON.parse(http_response)['data']

      raw_data.each do |account_insight|
        AccountInsight.create(
          account_id:    account_id,
          impressions:   account_insight['impressions'],
          spend:         account_insight['spend'],
          date:          account_insight['date_start']
        )

        unless account_insight['actions'].nil?
          account_insight['actions'].each do |action|
            Action.create(
              action_type: action['action_type'],
              value:       action['value'],
              date:        account_insight['date_start'],
              account_id:  account_id
            )
          end
        end
      end

      # Age & Gender Breakdown
      http_response = RestClient.get "#{BASE_URL}/#{account_id}/insights",
                                     {:params => {'access_token' => ACCESS_TOKEN,
                                                  'date_preset' => 'lifetime',
                                                  'time_increment' => 1,
                                                  'limit' => 1000,
                                                  'breakdowns' => ['age', 'gender'],
                                                  'fields' => account_insight_columns
                                                  }}

      raw_data = JSON.parse(http_response)['data']

      raw_data.each do |account_insight|
        unless account_insight['actions'].nil?
          account_insight['actions'].each do |action|
            Action.create(
              action_type: action['action_type'],
              value: action['value'],
              date: account_insight['date_start'],
              account_id: account_id,
              age: account_insight['age'],
              gender:  account_insight['gender']
            )
          end
        end
      end
    end

    # Output Account Insight and Action Data
    puts "Account Insights Created: #{AccountInsight.count}"
    puts "Account Actions Created: #{Action.count}"
  end

  def self.build_campaigns
    Campaign.delete_all

    # Set Campaign IDs
    campaign_ids = set_campaign_ids

    campaign_columns = ['date_start','date_stop','account_id','campaign_id',
                        'campaign_name','objective','impressions','spend',
                        'frequency','reach']

    campaign_ids.each do |campaign_id|
      http_response = RestClient.get "#{BASE_URL}/#{campaign_id['id']}/insights",
                                     {:params => {'access_token' => ACCESS_TOKEN,
                                                  'date_preset' => 'lifetime',
                                                  'fields' => campaign_columns,
                                                  'breakdowns' => 'placement'}}

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
          reach:         campaign['reach'],
        )
      end
    end

    # Output Campaign Data
    puts "Campaigns Created: #{Campaign.count}"
  end

  def self.build_campaigns_insights
    CampaignInsight.delete_all
    CampaignAction.delete_all

    # Set Campaign IDs
    campaign_ids = set_campaign_ids

    campaign_insights_columns = ['account_id','actions','campaign_name',
                                 'objective']

    campaign_ids.each do |campaign_id|
      http_response = RestClient.get "#{BASE_URL}/#{campaign_id['id']}/insights",
                                      {:params => {'access_token' => ACCESS_TOKEN,
                                                   'fields' => campaign_insights_columns,
                                                   'date_preset' => 'lifetime'}}

      raw_data = JSON.parse(http_response)['data']

      raw_data.each do |campaign_insight|
        CampaignInsight.create(
          account_id:    campaign_insight['account_id'],
          campaign_id:   campaign_id,
          objective:     campaign_insight['objective'],
          campaign_name: campaign_insight['campaign_name']
        )

        campaign_insight['actions'].each do |action|
          unless campaign_insight['actions'].nil?
            CampaignAction.create(
              action_type: action['action_type'],
              value: action['value'],
              account_id: campaign_insight['account_id'],
              campaign_id: campaign_id,
              campaign_name: campaign_insight['campaign_name'],
              objective: campaign_insight['objective'],
              audience: campaign_insight['campaign_name'].split('|')[1].strip
            )
          end
        end
      end
    end

    # Output Campaign Insight and Campaign Action Data
    puts "Campaign Insights Created: #{CampaignInsight.count}"
    puts "Campaigns Actions Created: #{CampaignAction.count}"
  end

  def self.build_ads
    Ad.delete_all

    ad_columns = ['account_id','ad_id','ad_name','campaign_id','objective',
                  'impressions','spend','frequency','reach']

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
          objective: ad['objective'],
          impressions: ad['impressions'],
          spend: ad['spend'],
          frequency: ad['frequency'],
          reach: ad['reach'],
          placement: ad['placement']
        )
      end

      # Output Ad Data
      puts "Ads Created: #{Ad.count}"
    end
  end

  private

  def self.account_ids
    # Account.pluck('account_id').uniq
    ['act_1219093434772270']
    # ['act_1219093704772243', 'act_1219093848105562', 'act_1219094361438844', 'act_1219094488105498', 'act_1219094644772149']
  end

  def self.set_campaign_ids
    campaign_ids = []

    account_ids.each do |account_id|
      http_response = RestClient.get "#{BASE_URL}/act_1219093434772270/campaigns",
                                      {:params => {'access_token' => ACCESS_TOKEN,
                                                   'date_preset' => 'lifetime'}}

      raw_data = JSON.parse(http_response)['data']

      raw_data.each do |data|
        campaign_ids.push(data)
      end
    end

    return campaign_ids
  end
end
