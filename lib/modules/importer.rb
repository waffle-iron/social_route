module Importer
  require 'rest-client'

  BASE_URL = 'https://graph.facebook.com/v2.6/'
  ACCESS_TOKEN = 'EAANNAsbKK4kBACpwFhVmwa7towVzr1plzrFYA7NxwGG5UZB2Qa7uXZBUzduKLT7GdtGYkODGZCG0Uz6hAYW6rw12XAd0k5T9N9L5ldOft6ZB0WtFOAZBi60euPVVXvEXJ7LoTBwe2ihPWOhJ5x7jYZA7ftHTHNw8kZD'

  def self.import
    puts "----------------------------------------------------".colorize(:green)
    puts "Start Import Rake Task... \n".colorize(:yellow)
    build_accounts
    build_account_insights
    build_campaigns
    build_adsets
    build_ads
    puts "| Import sucessfull \n\n".colorize(:yellow)
    puts "----------------------------------------------------".colorize(:green)
  end

  def self.build_accounts
    puts "----------------------------------------------------".colorize(:green)
    puts "| Generate Account Data                            |".colorize(:green)
    puts "----------------------------------------------------".colorize(:green)
    puts "| Building Account Data                            |".colorize(:green)

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

    puts "| Accounts: #{Account.count}".colorize(:green)
    puts "| Done".colorize(:green)
  end

  def self.build_account_insights
    puts "---------------------------------------------------|".colorize(:green)
    puts "| Building Account Insight Data                    |".colorize(:green)

    AccountInsight.delete_all
    Action.delete_all
    AccountPlacement.delete_all

    account_ids.each do |account_id|
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

      http_response = RestClient.get "#{BASE_URL}/#{account_id}/insights",
                                     {:params => {'access_token' => ACCESS_TOKEN,
                                                  'date_preset' => 'lifetime',
                                                  'breakdowns' => ['placement'],
                                                  'limit' => 1000
                                                  }}

      raw_data = JSON.parse(http_response)['data']

      raw_data.each do |account_placement|
        AccountPlacement.create(
          date_start:  account_placement['date_start'],
          date_stop:   account_placement['date_stop'],
          account_id:  account_placement['account_id'],
          impressions: account_placement['impressions'],
          spend:       account_placement['spend'],
          placement:   account_placement['placement']
        )
      end
    end

    puts "| Account Insights: #{AccountInsight.count}".colorize(:green)
    puts "| Account Actions: #{Action.count}".colorize(:green)
    puts "| Account Placements: #{AccountPlacement.count}".colorize(:green)
    puts "| Done".colorize(:green)
  end

  def self.build_campaigns
    puts "---------------------------------------------------|".colorize(:green)
    puts "----------------------------------------------------".colorize(:green)
    puts "| Building Campaign Data                           |".colorize(:green)

    Campaign.delete_all
    CampaignAction.delete_all

    account_ids.each do |account_id|
      campaign_columns = ['date_start','date_stop','account_id','campaign_id',
                          'campaign_name','objective','impressions','spend',
                          'frequency','reach','actions','cpm']

      http_response = RestClient.get "#{BASE_URL}/#{account_id}/insights",
                                     {:params => {'access_token' => ACCESS_TOKEN,
                                                  'date_preset' => 'lifetime',
                                                  'limit' => 1000,
                                                  'fields' => campaign_columns,
                                                  'level' => 'campaign'}}

      raw_data = JSON.parse(http_response)['data']

      raw_data.each do |campaign|
        total_bars = bar_count(campaign['campaign_name'])

        if total_bars > 0
          audience = campaign['campaign_name'].split('|')[1].strip.gsub(/[\s,]/ ,"")
        else
          audience = "POST"
        end

        Campaign.create(
          date_start:    campaign['date_start'],
          date_stop:     campaign['date_stop'],
          account_id:    campaign['account_id'],
          campaign_id:   campaign['campaign_id'],
          campaign_name: campaign['campaign_name'],
          objective:     campaign['objective'],
          impressions:   campaign['impressions'],
          spend:         campaign['spend'],
          frequency:     campaign['frequency'],
          reach:         campaign['reach'],
          cpm:           campaign['cpm'],
          audience:      audience
        )

        unless campaign['actions'].nil?
          campaign['actions'].each do |action|
            CampaignAction.create(
              action_type:   action['action_type'],
              value:         action['value'],
              account_id:    campaign['account_id'],
              campaign_id:   campaign['campaign_id'],
              campaign_name: campaign['campaign_name'],
              objective:     campaign['objective'],
              audience:      audience
            )
          end
        end
      end
    end

    puts "| Campaigns: #{Campaign.count}"
    puts "| Campaigns Actions: #{CampaignAction.count}"
    puts "| Done                                             |".colorize(:green)
  end

  def self.build_adsets
    Adset.delete_all
    AdsetTargeting.delete_all

    adset_columns = ['name','campaign_id','daily_budget','targeting','status']

    account_ids.each do |account_id|
      http_response = RestClient.get "#{BASE_URL}/#{account_id}/adsets",
                                      {:params => {'access_token' => ACCESS_TOKEN,
                                                   'fields' => adset_columns,
                                                   'limit' => 1000,
                                                   'date_preset' => 'lifetime'}}

      raw_data = JSON.parse(http_response)['data']

      raw_data.each do |adset|
        interests = []
        cities = []

        total_bars = bar_count(adset['name'])

        if total_bars > 0
          audience = adset['name'].split('|')[3].strip.gsub(/[\s,]/ ,"")
        else
          audience = "POST"
        end

        Adset.create(
          name:         adset['name'],
          adset_id:     adset['id'],
          account_id:   account_id,
          campaign_id:  adset['campaign_id'],
          status:       adset['status'],
          daily_budget: adset['daily_budget'],
          audience:     audience,
          targeting:    adset['targeting']
        )

        if adset['targeting']
          if adset['targeting']['flexible_spec']
            adset['targeting']['flexible_spec'].each do |data|
              if data['interests']
                data['interests'].each do |interest|
                  interests.push(interest['name'])
                end
              end
            end
          end
        end

        if adset['targeting']
          if adset['targeting']['geo_locations']
            if adset['targeting']['geo_locations']['cities']
              adset['targeting']['geo_locations']['cities'].each do |data|
                cities.push("#{data['name']} - #{data['radius']} mi")
              end
            end
          end
        end

        AdsetTargeting.create(
          age_min: adset['targeting']['age_min'],
          age_max: adset['targeting']['age_max'],
          account_id: account_id,
          campaign_id: adset['campaign_id'],
          adset_id: adset['id'],
          audience: audience,
          interests: interests,
          cities: cities
        )
      end
    end

    puts "Adsets Created: #{Adset.count}"
    puts "Adsets Tagets Created: #{AdsetTargeting.count}"
  end

  def self.build_ads
    Ad.delete_all

    ad_columns = ['account_id','ad_id','ad_name','campaign_id','objective',
                  'impressions','spend','frequency','reach',
                  'campaign_name', 'adset_id']

    account_ids.each do |account_id|
      raw_data = JSON.parse(RestClient.get "#{BASE_URL}/#{account_id}/insights",
                                          {:params => {'access_token' => ACCESS_TOKEN,
                                                       'date_preset' =>'lifetime',
                                                       'level' => 'ad',
                                                       'fields' => ad_columns,
                                                       'limit' => 1000}})['data']

      raw_data.each do |ad|
        total_bars_ad_name = bar_count(ad['ad_name'])

        if total_bars_ad_name == 4
          simple_name = ad['ad_name'].split('|')[0].to_s.strip
          format = ad['ad_name'].split('|')[3].to_s.strip
          edition = ad['ad_name'].split('|')[4].to_s.strip
        elsif total_bars_ad_name == 3
          simple_name = ad['ad_name'].split('|')[0].to_s.strip
          format = ad['ad_name'].split('|')[2].to_s.strip
          edition = ad['ad_name'].split('|')[3].to_s.strip
        else
          simple_name = 'Mislabeled'
          format = 'Mislabeled'
          edition = nil
        end

        total_bars = bar_count(ad['campaign_name'])

        if total_bars > 0
          audience = ad['campaign_name'].split('|')[1].strip.gsub(/[\s,]/ ,"")
        else
          audience = "POST"
        end

        Ad.create(
          account_id:    ad['account_id'],
          ad_id:         ad['ad_id'],
          adset_id:      ad['adset_id'],
          ad_name:       ad['ad_name'],
          simple_name:   simple_name,
          campaign_id:   ad['campaign_id'],
          campaign_name: ad['campaign_name'],
          objective:     ad['objective'],
          impressions:   ad['impressions'],
          spend:         ad['spend'],
          frequency:     ad['frequency'],
          reach:         ad['reach'],
          audience:      audience,
          format:        format,
          edition:       edition
        )
      end
    end

    puts "Ads Created: #{Ad.count}"
  end

  private

  def self.account_ids
    # Musuem Accounts
    # ['act_1219094488105498','act_1219094361438844','act_1219093704772243','act_1219093848105562','act_1219093434772270']

    # Rickebaugh
    # ['act_1139120289436252', 'act_1130403580307923', 'act_1130403223641292']

    # Tynan's
    ['act_1253619597986320', 'act_1219616701386610']
  end

  def self.set_campaign_ids(account_id)
    campaign_ids = []

    http_response = RestClient.get "#{BASE_URL}/#{account_id}/campaigns",
                                    {:params => {'access_token' => ACCESS_TOKEN,
                                                 'date_preset' => 'lifetime',
                                                 'limit' => 1000}}

    raw_data = JSON.parse(http_response)['data']

    raw_data.each do |data|
      campaign_ids.push(data)
    end

    return campaign_ids
  end

  def self.bar_count(string)
    string.count('|')
  end
end
