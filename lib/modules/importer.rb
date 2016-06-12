module Importer
  require 'rest-client'

  BASE_URL = 'https://graph.facebook.com/v2.6/'
  ACCESS_TOKEN = 'EAANNAsbKK4kBACpwFhVmwa7towVzr1plzrFYA7NxwGG5UZB2Qa7uXZBUzduKLT7GdtGYkODGZCG0Uz6hAYW6rw12XAd0k5T9N9L5ldOft6ZB0WtFOAZBi60euPVVXvEXJ7LoTBwe2ihPWOhJ5x7jYZA7ftHTHNw8kZD'

  def self.import
    puts "----------------------------------------------------".colorize(:green)
    puts "Start Import Rake Task... \n".colorize(:yellow)
    build_accounts
    build_account_insights
    build_account_creatives
    build_ad_creative_lookup
    build_campaigns
    build_adsets
    build_ads
    puts "----------------------------------------------------".colorize(:green)
    puts "\n\nImport sucessfull".colorize(:yellow)
  end

  def self.build_accounts
    puts "----------------------------------------------------".colorize(:green)
    puts "| Building Account Data                            |".colorize(:green)

    account_columns = ['name', 'account_status', 'amount_spent']

    http_response = RestClient.get "#{BASE_URL}/me/adaccounts",
                                   {:params => {'access_token' => ACCESS_TOKEN,
                                                'fields' => account_columns,
                                                'limit' => 1000}}
    raw_data = JSON.parse(http_response)['data']

    account_data = Array.new

    raw_data.each do |account|
      account_data.push({account_id:     account['id'],
                         account_status: account['account_status'],
                         amount_spent:   account['amount_spent'],
                         name:           account['name']})
    end

    Account.transaction do
      Account.delete_all
      Account.create!(account_data)
    end

    puts "| Accounts: #{Account.count}".colorize(:green)
    puts "| Done".colorize(:green)
  end

  def self.build_account_insights
    puts "---------------------------------------------------|".colorize(:green)
    puts "| Building Account Insight Data                    |".colorize(:green)

    account_insights = Array.new
    account_actions = Array.new
    account_placements = Array.new

    account_ids.each do |account_id|
      account_insight_columns = ['impressions','actions']

      http_response = RestClient.get "#{BASE_URL}/#{account_id}/insights",
                                     {:params => {'access_token' => ACCESS_TOKEN,
                                                  'date_preset' => 'lifetime',
                                                  'time_increment' => 1,
                                                  'limit' => 1000,
                                                  'fields' => account_insight_columns
                                                  }}

      raw_data = JSON.parse(http_response)['data']


      raw_data.each do |account_insight|
        account_insights.push({account_id:  account_id,
                               impressions: account_insight['impressions']})

        unless account_insight['actions'].nil?
          account_insight['actions'].each do |action|
            account_actions.push({action_type: action['action_type'],
                                  value:       action['value'],
                                  date:        account_insight['date_start'],
                                  account_id:  account_id})
          end
        end
      end

      http_response = RestClient.get "#{BASE_URL}/#{account_id}/insights",
                                     {:params => {'access_token' => ACCESS_TOKEN,
                                                  'date_preset' => 'lifetime',
                                                  'time_increment' => 1,
                                                  'limit' => 1000,
                                                  'breakdowns' => ['age', 'gender'],
                                                  'fields' => account_insight_columns}}

      raw_data = JSON.parse(http_response)['data']

      raw_data.each do |account_insight|
        unless account_insight['actions'].nil?
          account_insight['actions'].each do |action|
            account_actions.push({action_type: action['action_type'],
                                  value:       action['value'],
                                  date:        account_insight['date_start'],
                                  account_id:  account_id,
                                  age:         account_insight['age'],
                                  gender:      account_insight['gender']})
          end
        end
      end

      http_response = RestClient.get "#{BASE_URL}/#{account_id}/insights",
                                     {:params => {'access_token' => ACCESS_TOKEN,
                                                  'date_preset' => 'lifetime',
                                                  'breakdowns' => ['placement'],
                                                  'limit' => 1000}}

      raw_data = JSON.parse(http_response)['data']

      raw_data.each do |account_placement|
        account_placements.push({date_start:  account_placement['date_start'],
                                 date_stop:   account_placement['date_stop'],
                                 account_id:  account_placement['account_id'],
                                 impressions: account_placement['impressions'],
                                 spend:       account_placement['spend'],
                                 placement:   account_placement['placement']})
      end
    end

    AccountInsight.transaction do
      AccountInsight.delete_all
      AccountInsight.create!(account_insights)
    end

    Action.transaction do
      Action.delete_all
      Action.create!(account_actions)
    end

    AccountPlacement.transaction do
      AccountPlacement.delete_all
      AccountPlacement.create!(account_placements)
    end

    puts "| Account Insights: #{AccountInsight.count}".colorize(:green)
    puts "| Account Actions: #{Action.count}".colorize(:green)
    puts "| Account Placements: #{AccountPlacement.count}".colorize(:green)
    puts "| Done".colorize(:green)
  end

  def self.build_account_creatives
    puts "---------------------------------------------------|".colorize(:green)
    puts "| Building Account Creative Data                   |".colorize(:green)

    ad_account_creatives = Array.new

    account_ids.each do |account_id|
      account_creative_fields = ['image_url', 'thumbnail_url']

      http_response = RestClient.get "#{BASE_URL}/#{account_id}/adcreatives",
                                     {:params => {'access_token' => ACCESS_TOKEN,
                                                  'date_preset' => 'lifetime',
                                                  'limit' => 1000,
                                                  'fields' => account_creative_fields
                                                  }}

      raw_data = JSON.parse(http_response)['data']

      raw_data.each do |account_creative|
        ad_account_creatives.push({creative_id:   account_creative['id'],
                                   image_url:     account_creative['image_url'],
                                   thumbnail_url: account_creative['thumbnail_url']})
      end
    end

    AdAccountCreative.transaction do
      AdAccountCreative.delete_all
      AdAccountCreative.create!(ad_account_creatives)
    end

    puts "| Account Creatives: #{AdAccountCreative.count}".colorize(:green)
    puts "| Done".colorize(:green)
  end

  def self.build_ad_creative_lookup
    puts "---------------------------------------------------|".colorize(:green)
    puts "| Building Account Creative Lookup Data            |".colorize(:green)

    ad_creative_lookups = Array.new

    account_ids.each do |account_id|
      ad_creative_lookup_fields = ['creative']

      http_response = RestClient.get "#{BASE_URL}/#{account_id}/ads",
                                     {:params => {'access_token' => ACCESS_TOKEN,
                                                  'date_preset' => 'lifetime',
                                                  'limit' => 1000,
                                                  'fields' => ad_creative_lookup_fields
                                                  }}

      raw_data = JSON.parse(http_response)['data']

      raw_data.each do |ad_creative_lookup|
        ad_creative_lookups.push({creative_id:  ad_creative_lookup['creative']['id'],
                                  ad_id:        ad_creative_lookup['id']})
      end
    end

    AdCreativeLookup.transaction do
      AdCreativeLookup.delete_all
      AdCreativeLookup.create!(ad_creative_lookups)
    end

    puts "| Account Creative Lookups Created: #{AdCreativeLookup.count}".colorize(:green)
    puts "| Done".colorize(:green)
  end

  def self.build_campaigns
    puts "---------------------------------------------------|".colorize(:green)
    puts "----------------------------------------------------".colorize(:green)
    puts "| Building Campaign Data                           |".colorize(:green)

    campaigns = Array.new
    campaign_actions = Array.new

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
          audience = 'POST'
        end

        campaigns.push({date_start:    campaign['date_start'],
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
                        audience:      audience})

        unless campaign['actions'].nil?
          campaign['actions'].each do |action|
            campaign_actions.push({action_type:   action['action_type'],
                                   value:         action['value'],
                                   account_id:    campaign['account_id'],
                                   campaign_id:   campaign['campaign_id'],
                                   campaign_name: campaign['campaign_name'],
                                   objective:     campaign['objective'],
                                   audience:      audience})
          end
        end
      end
    end

    Campaign.transaction do
      Campaign.delete_all
      Campaign.create!(campaigns)
    end

    CampaignAction.transaction do
      CampaignAction.delete_all
      CampaignAction.create!(campaign_actions)
    end

    puts "| Campaigns: #{Campaign.count}"
    puts "| Campaigns Actions: #{CampaignAction.count}"
    puts "| Done                                             |".colorize(:green)
  end

  def self.build_adsets
    adsets = Array.new
    adset_targetings = Array.new
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

        if total_bars > 3
          audience = adset['name'].split('|')[3].strip.gsub(/[\s,]/ ,"")
        else
          audience = "POST"
        end

        adsets.push({name:         adset['name'],
                     adset_id:     adset['id'],
                     account_id:   account_id,
                     campaign_id:  adset['campaign_id'],
                     status:       adset['status'],
                     daily_budget: adset['daily_budget'],
                     audience:     audience,
                     targeting:    adset['targeting']})

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

        if adset['targeting']
          adset_targetings.push({age_min: adset['targeting']['age_min'],
                                 age_max: adset['targeting']['age_max'],
                                 account_id: account_id,
                                 campaign_id: adset['campaign_id'],
                                 adset_id: adset['id'],
                                 audience: audience,
                                 interests: interests,
                                 cities: cities})
        end
      end
    end

    Adset.transaction do
      Adset.delete_all
      Adset.create!(adsets)
    end

    AdsetTargeting.transaction do
      AdsetTargeting.delete_all
      AdsetTargeting.create!(adset_targetings)
    end

    puts "Adsets Created: #{Adset.count}"
    puts "Adsets Tagets Created: #{AdsetTargeting.count}"
  end

  def self.build_ads
    ads = Array.new

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

        ads.push({account_id:    ad['account_id'],
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
                  edition:       edition})
      end
    end

    Ad.transaction do
      Ad.delete_all
      Ad.create!(ads)
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
    # ['act_1253619597986320', 'act_1219616701386610']

    # Top 25
    ['act_1219094644772149', 'act_1219093434772270', 'act_1219094751438805',
     'act_1219094488105498', 'act_1219616701386610', 'act_1130403580307923',
     'act_1139120289436252', 'act_1130403223641292', 'act_1253619597986320',
     'act_1264926836855596', 'act_1374748469467327', 'act_937799526234997',
     'act_1382151058724804', 'act_1382716158668218', 'act_1096482140366734',
     'act_1382519912021865', 'act_923549197660030', 'act_256023237923821',
     'act_1033441906670758', 'act_965932350088381', 'act_1380511028896841',
     'act_1219093704772243', 'act_1219094968105450', 'act_944470208901262',
     'act_331941523628320']

  end

  def self.bar_count(string)
    string.count('|')
  end
end
