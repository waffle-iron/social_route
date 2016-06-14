module Importer
  require 'rest-client'
  require 'activerecord-import/base'

  ActiveRecord::Import.require_adapter('mysql2')

  BASE_URL = 'https://graph.facebook.com/v2.6/'
  ACCESS_TOKEN = 'EAANNAsbKK4kBACpwFhVmwa7towVzr1plzrFYA7NxwGG5UZB2Qa7uXZBUzduKLT7GdtGYkODGZCG0Uz6hAYW6rw12XAd0k5T9N9L5ldOft6ZB0WtFOAZBi60euPVVXvEXJ7LoTBwe2ihPWOhJ5x7jYZA7ftHTHNw8kZD'

  def self.import
    start = Time.now
    puts start.to_s.colorize(:yellow)
    puts "----------------------------------------------------".colorize(:yellow)
    puts "Start Import Rake Task... \n".colorize(:yellow)
    # build_accounts
    # build_account_creatives
    # build_ad_creative_lookup
    # build_campaigns
    # build_adsets
    # build_ads
    build_ads_v2
    # build_ads_v2_placement
    # build_ads_v2_age_and_gender
    puts "----------------------------------------------------".colorize(:yellow)
    puts "\n\nImport sucessfull".colorize(:yellow)
    puts "#{Time.now - start}".to_s.colorize(:yellow)
  end

  def self.build_accounts
    puts "----------------------------------------------------".colorize(:yellow)
    puts "| Building Account Data                            |".colorize(:yellow)

    account_columns = ['name', 'account_status', 'amount_spent']

    http_response = RestClient.get "#{BASE_URL}/me/adaccounts",
                                   {:params => {'access_token' => ACCESS_TOKEN,
                                                'fields' => account_columns,
                                                'limit' => 1000}}
    raw_data = JSON.parse(http_response)['data']

    account_data = Array.new

    raw_data.each do |account|
      account_data << Account.new(account_id:     account['id'],
                                  account_status: account['account_status'],
                                  amount_spent:   account['amount_spent'],
                                  name:           account['name'])
    end

    Account.transaction do
      Account.delete_all
      Account.import account_data, :validate => false
    end

    puts "| Accounts: #{Account.count}".colorize(:yellow)
    puts "| Done".colorize(:yellow)
  end

  def self.build_account_creatives
    puts "---------------------------------------------------|".colorize(:yellow)
    puts "| Building Account Creative Data                   |".colorize(:yellow)

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

    AdAccountCreative.delete_all
    AdAccountCreative.bulk_insert values: ad_account_creatives

    puts "| Account Creatives: #{AdAccountCreative.count}".colorize(:yellow)
    puts "| Done".colorize(:yellow)
  end

  def self.build_ad_creative_lookup
    puts "---------------------------------------------------|".colorize(:yellow)
    puts "| Building Account Creative Lookup Data            |".colorize(:yellow)

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

    AdCreativeLookup.delete_all
    AdCreativeLookup.bulk_insert values: ad_creative_lookups

    puts "| Account Creative Lookups Created: #{AdCreativeLookup.count}".colorize(:yellow)
    puts "| Done".colorize(:yellow)
  end

  def self.build_campaigns
    puts "---------------------------------------------------|".colorize(:yellow)
    puts "----------------------------------------------------".colorize(:yellow)
    puts "| Building Campaign Data                           |".colorize(:yellow)

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
                        audience:      audience,
                        name_flagged:  campaign_name_flagged(campaign['campaign_name'])})

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

    Campaign.delete_all
    Campaign.bulk_insert values: campaigns

    CampaignAction.delete_all
    CampaignAction.bulk_insert values: campaign_actions

    puts "| Campaigns: #{Campaign.count}".colorize(:yellow)
    puts "| Campaigns Actions: #{CampaignAction.count}".colorize(:yellow)
    puts "| Done                                             |".colorize(:yellow)
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

        adsets << Adset.new(name:         adset['name'],
                     adset_id:     adset['id'],
                     account_id:   account_id,
                     campaign_id:  adset['campaign_id'],
                     status:       adset['status'],
                     daily_budget: adset['daily_budget'],
                     audience:     audience,
                     name_flagged: adset_name_flagged(adset['name']))

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
          adset_targetings << AdsetTargeting.new(age_min: adset['targeting']['age_min'],
                                 age_max: adset['targeting']['age_max'],
                                 account_id: account_id,
                                 campaign_id: adset['campaign_id'],
                                 adset_id: adset['id'],
                                 audience: audience)
                                #  interests: interests,
                                #  cities: cities)
        end
      end
    end

    Adset.delete_all
    Adset.import adsets, :validate => false

    AdsetTargeting.delete_all
    AdsetTargeting.import adset_targetings, :validate => false

    puts "Adsets Created: #{Adset.count}".colorize(:yellow)
    puts "Adsets Tagets Created: #{AdsetTargeting.count}".colorize(:yellow)
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
                  edition:       edition,
                  name_flagged:  ad_name_flagged(ad['ad_name'])
                  })
      end
    end

    Ad.delete_all
    Ad.bulk_insert values: ads

    puts "Ads Created: #{Ad.count}".colorize(:yellow)
  end

  def self.build_ads_v2
    ads = Array.new
    ad_actions = Array.new

    ad_columns = ['account_id', 'campaign_id', 'adset_id', 'ad_id', 'ad_name',
                  'objective', 'impressions', 'spend', 'frequency', 'reach',
                  'date_start', 'date_stop', 'campaign_name', 'actions']

    account_ids.each do |account_id|
      raw_data = JSON.parse(RestClient.get "#{BASE_URL}/#{account_id}/insights",
                                          {:params => {'access_token' => ACCESS_TOKEN,
                                                       'date_preset' =>'lifetime',
                                                       'level' => 'ad',
                                                       'fields' => ad_columns,
                                                       'limit' => 1000}})['data']

      raw_data.each do |ad|
        audience = extract_audience_name(ad['campaign_name'])
        ad_format = extract_ad_format(ad['ad_name'])
        simple_name = extract_ad_edition(ad['ad_name'])
        edition = extract_ad_simple_name(ad['ad_name'])

        ads.push({account_id:  ad['account_id'],
                  campaign_id: ad['campaign_id'],
                  adset_id:    ad['adset_id'],
                  ad_id:       ad['ad_id'],
                  ad_name:     ad['ad_name'],
                  objective:   ad['objective'],
                  impressions: ad['impressions'],
                  spend:       ad['spend'],
                  frequency:   ad['frequency'],
                  reach:       ad['reach'],
                  date_start:  ad['date_start'],
                  date_stop:   ad['date_stop'],
                  audience:    audience,
                  format:      ad_format,
                  simple_name: simple_name,
                  edition:     edition
                })

        unless ad['actions'].nil?
          ad['actions'].each do |action|
            ad_actions.push({account_id:  ad['account_id'],
                             ad_id:       ad['ad_id'],
                             action_type: action['action_type'],
                             value:       action['value'],
                             objective:   ad['objective'],
                             audience:    audience,
                             format:      ad_format,
                             simple_name: simple_name,
                             edition:     edition
                            })
          end
        end
      end
    end


    Ad2.delete_all
    Ad2.bulk_insert values: ads

    Ad2Action.delete_all
    Ad2Action.bulk_insert values: ad_actions

    puts "Ads Created: #{Ad2.count}".colorize(:yellow)
    puts "Ads Actions Created: #{Ad2Action.count}".colorize(:yellow)
  end

  def self.build_ads_v2_placement
    ads = Array.new
    ad_actions = Array.new

    ad_columns = ['account_id', 'campaign_id', 'adset_id', 'ad_id', 'ad_name',
                  'objective', 'impressions', 'spend', 'frequency', 'reach',
                  'actions']

    account_ids.each do |account_id|
      raw_data = JSON.parse(RestClient.get "#{BASE_URL}/#{account_id}/insights",
                                          {:params => {'access_token' => ACCESS_TOKEN,
                                                       'date_preset' =>'lifetime',
                                                       'level' => 'ad',
                                                       'fields' => ad_columns,
                                                       'breakdowns' => 'placement',
                                                       'limit' => 1000}})['data']

      raw_data.each do |ad|
        ads.push({account_id:  ad['account_id'],
                  campaign_id: ad['campaign_id'],
                  adset_id:    ad['adset_id'],
                  ad_id:       ad['ad_id'],
                  ad_name:     ad['ad_name'],
                  objective:   ad['objective'],
                  impressions: ad['impressions'],
                  spend:       ad['spend'],
                  frequency:   ad['frequency'],
                  reach:       ad['reach'],
                  placement:   ad['placement']
                })

        unless ad['actions'].nil?
          ad['actions'].each do |action|
            ad_actions.push({account_id:  ad['account_id'],
                             action_type: action['action_type'],
                             value:       action['value'],
                             objective:   ad['objective'],
                             placement:   ad['placement']})
          end
        end
      end
    end


    Ad2Placement.delete_all
    Ad2Placement.bulk_insert values: ads

    Ad2PlacementAction.delete_all
    Ad2PlacementAction.bulk_insert values: ad_actions

    puts "Ads Placement Created: #{Ad2Placement.count}".colorize(:yellow)
    puts "Ads Placement Actions Created: #{Ad2PlacementAction.count}".colorize(:yellow)
  end

  def self.build_ads_v2_age_and_gender
    ad_actions = Array.new

    account_ids.each do |account_id|
      raw_data = JSON.parse(RestClient.get "#{BASE_URL}/#{account_id}/insights",
                                          {:params => {'access_token' => ACCESS_TOKEN,
                                                       'date_preset' =>'lifetime',
                                                       'level' => 'ad',
                                                       'fields' => ['account_id', 'actions'],
                                                       'breakdowns' => ['age', 'gender'],
                                                       'limit' => 1000}})['data']

      raw_data.each do |ad|
        unless ad['actions'].nil?
          ad['actions'].each do |action|
            ad_actions.push({account_id:  ad['account_id'],
                             action_type: action['action_type'],
                             value:       action['value'],
                             age:         ad['age'],
                             gender:      ad['gender']})
          end
        end
      end
    end

    Ad2AgeAndGenderAction.delete_all
    Ad2AgeAndGenderAction.bulk_insert values: ad_actions

    puts "Ads Age and Gender Actions Created: #{Ad2AgeAndGenderAction.count}".colorize(:yellow)
  end

  private

  def self.account_ids
    # Musuem Accounts
    # ['act_1219094488105498','act_1219094361438844','act_1219093704772243','act_1219093848105562','act_1219093434772270']

    # Rickebaugh
    # ['act_1139120289436252', 'act_1130403580307923', 'act_1130403223641292']

    # Tynan's
    # ['act_1253619597986320', 'act_1219616701386610']

    # Yogurtland
    # ['act_965932350088381']

    # Robots Exhibit
    ['act_1219093434772270']

    # Top 25
    # ['act_1219094644772149', 'act_1219093434772270', 'act_1219094751438805',
    #  'act_1219094488105498', 'act_1219616701386610', 'act_1130403580307923',
    #  'act_1139120289436252', 'act_1130403223641292', 'act_1253619597986320',
    #  'act_1264926836855596', 'act_1374748469467327', 'act_937799526234997',
    #  'act_1382151058724804', 'act_1382716158668218', 'act_1096482140366734',
    #  'act_1382519912021865', 'act_923549197660030', 'act_256023237923821',
    #  'act_1033441906670758', 'act_965932350088381', 'act_1380511028896841',
    #  'act_1219093704772243', 'act_1219094968105450', 'act_944470208901262',
    #  'act_331941523628320']

  end

  def self.bar_count(string)
    string.count('|')
  end

  def self.extract_audience_name(campaign_name)
    total_bars = campaign_name.count('|')

    puts campaign_name
    puts total_bars

    if total_bars > 0
      return campaign_name.split('|')[1].strip.gsub(/[\s,]/ ,"")
    else
      return "POST"
    end
  end

  def self.extract_ad_format(ad_name)
    total_bars = ad_name.count('|')

    if total_bars == 4
      return ad_name.split('|')[3].to_s.strip
    elsif total_bars == 3
      return ad_name.split('|')[2].to_s.strip
    else
      return nil
    end
  end

  def self.extract_ad_edition(ad_name)
    total_bars = ad_name.count('|')

    if total_bars == 4
      return ad_name.split('|')[0].to_s.strip
    elsif total_bars == 3
      return ad_name.split('|')[0].to_s.strip
    else
      return 'POST'
    end
  end

  def self.extract_ad_simple_name(ad_name)
    total_bars = ad_name.count('|')

    if total_bars == 4
      return ad_name.split('|')[4].to_s.strip
    elsif total_bars == 3
      return ad_name.split('|')[3].to_s.strip
    else
      return nil
    end
  end

  def self.campaign_name_flagged(campaign_name)
    bar_count = campaign_name.count('|')

    if campaign_name.include?("Post")
      post = true
    else
      post = false
    end

    if !post && bar_count != 2
      return true
    else
      return false
    end
  end

  def self.adset_name_flagged(adset_name)
    bar_count = adset_name.count('|')

    if adset_name.include?("Post:")
      post = true
    else
      post = false
    end

    if bar_count < 3 && !post
      return true
    else
      return false
    end
  end

  def self.ad_name_flagged(ad_name)
    bar_count = ad_name.count('|')

    if ad_name.include?("Post:")
      post = true
    else
      post = false
    end

    if bar_count < 3 && !post
      return true
    else
      return false
    end
  end
end
