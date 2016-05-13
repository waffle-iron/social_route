module Importer
  require 'rest-client'

  BASE_URL = 'https://graph.facebook.com/v2.6/'
  ACCESS_TOKEN = 'EAANNAsbKK4kBAKuXwyMwfrcVG5rZBzfwFBdZCpEwxMwwqCZCwDDVXoLDxyXgR9BhfAHoPF2t6bIWpjq4b2zD46tfqrXfqKs079roEvl36oLRZCCELPGmpcq5X5K0i6oUlH4ktjMOKZBRFMMmojHANgxxPdzD1ZCT8ZD'

  def self.import
    puts "Start Import Rake Task... \n".colorize(:yellow)
    puts "--------------------------------------------------------------------".colorize(:green)
    puts "| Generate Account Data                                            |".colorize(:green)
    puts "--------------------------------------------------------------------".colorize(:green)
    puts "| Building Account Data                                            |".colorize(:green)
    # build_accounts
    puts "| Done                                                             |".colorize(:green)
    puts "| Building Account Insight Data                                    |".colorize(:green)
    # build_account_insights
    puts "| Done                                                             |".colorize(:green)
    puts "--------------------------------------------------------------------".colorize(:green)
    puts "| Generate Campaign Data                                           |".colorize(:green)
    puts "--------------------------------------------------------------------".colorize(:green)
    puts "| Building Campaign Data                                           |".colorize(:green)
    # build_campaigns
    puts "| Done                                                             |".colorize(:green)
    puts "| Building Campaign Insight Data                                   |".colorize(:green)
    # build_campaigns_insights
    puts "| Done                                                             |".colorize(:green)
    puts "--------------------------------------------------------------------".colorize(:green)
    puts "| Generate Ad Set Data                                             |".colorize(:green)
    puts "--------------------------------------------------------------------".colorize(:green)
    puts "| Building Ad Set Data                                             |".colorize(:green)
    # build_adsets
    puts "| Done                                                             |".colorize(:green)
    puts "| Building Account Insight Data                                    |".colorize(:green)
    build_adset_insights
    puts "| Done                                                             |".colorize(:green)
    puts "--------------------------------------------------------------------".colorize(:green)
    puts "| Generate Ad Data                                                 |".colorize(:green)
    puts "--------------------------------------------------------------------".colorize(:green)
    puts "| Building Ads Data                                                |".colorize(:green)
    # build_ads
    puts "| Done                                                             |".colorize(:green)
    puts "--------------------------------------------------------------------"
    puts "\nImport sucessfull \n\n".colorize(:yellow)
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

    account_ids.each do |account_id|

      # Set Campaign IDs
      campaign_ids = set_campaign_ids(account_id)

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
            audience:      campaign['campaign_name'].split('|')[1].strip,
            spend:         campaign['spend'],
            frequency:     campaign['frequency'],
            impressions:   campaign['impressions'],
            reach:         campaign['reach']
          )
        end
      end
    end

    # Output Campaign Data
    puts "Campaigns Created: #{Campaign.count}"
  end

  def self.build_campaigns_insights
    CampaignInsight.delete_all
    CampaignAction.delete_all

    account_ids.each do |account_id|
      # Set Campaign IDs
      campaign_ids = set_campaign_ids(account_id)

      campaign_insights_columns = ['account_id','actions','campaign_name',
                                   'objective','spend','impressions']

      campaign_ids.each do |campaign_id|
        http_response = RestClient.get "#{BASE_URL}/#{campaign_id['id']}/insights",
                                        {:params => {'access_token' => ACCESS_TOKEN,
                                                     'fields' => campaign_insights_columns,
                                                     'date_preset' => 'lifetime'}}

        raw_data = JSON.parse(http_response)['data']

        raw_data.each do |campaign_insight|
          CampaignInsight.create(
            account_id:    campaign_insight['account_id'],
            campaign_id:   campaign_id['id'],
            objective:     campaign_insight['objective'],
            campaign_name: campaign_insight['campaign_name'],
            spend:         campaign_insight['spend'],
            impressions:   campaign_insight['impressions'],
            audience:      campaign_insight['campaign_name'].split('|')[1].strip
          )

          campaign_insight['actions'].each do |action|
            unless campaign_insight['actions'].nil?
              CampaignAction.create(
                action_type: action['action_type'],
                value: action['value'],
                account_id: campaign_insight['account_id'],
                campaign_id: campaign_id['id'],
                campaign_name: campaign_insight['campaign_name'],
                objective: campaign_insight['objective'],
                audience: campaign_insight['campaign_name'].split('|')[1].strip
              )
            end
          end
        end
      end
    end

    # Output Campaign Insight and Campaign Action Data
    puts "Campaign Insights Created: #{CampaignInsight.count}"
    puts "Campaigns Actions Created: #{CampaignAction.count}"
  end

  def self.build_adsets
    Adset.delete_all

    adset_columns = ['name','adset_id','account_id','campaign_id','status',
                     'daily_budget']

    account_ids.each do |account_id|
      http_response = RestClient.get "#{BASE_URL}/#{account_id}/adsets",
                                      {:params => {'access_token' => ACCESS_TOKEN,
                                                   'fields' => adset_columns,
                                                   'limit' => 1000,
                                                   'date_preset' => 'lifetime'}}

      raw_data = JSON.parse(http_response)['data']

      raw_data.each do |adset|
        Adset.create(
          name:         adset['name'],
          adset_id:     adset['id'],
          account_id:   adset['account_id'],
          campaign_id:  adset['campaign_id'],
          status:       adset['status'],
          daily_budget: adset['daily_budget'],
          audience:     adset['name'].split('|')[3].strip
        )
      end
    end

    # Output Adset Data
    puts "Adsets Created: #{Adset.count}"
  end

  def self.build_adset_insights
    AdsetInsight.delete_all

    account_id, account_name, ad_id, ad_name, buying_type, campaign_id, campaign_name, adset_id, adset_name, objective, actions, unique_actions, total_actions, total_unique_actions, action_values, total_action_value, impressions, social_impressions, clicks, social_clicks, unique_impressions, unique_social_impressions, unique_clicks, unique_social_clicks, spend, frequency, social_spend, deeplink_clicks, app_store_clicks, website_clicks, cost_per_inline_post_engagement, inline_link_clicks, cost_per_inline_link_click, inline_post_engagement, unique_inline_link_clicks, cost_per_unique_inline_link_click, inline_link_click_ctr, unique_inline_link_click_ctr, call_to_action_clicks, newsfeed_avg_position, newsfeed_impressions, newsfeed_clicks, reach, social_reach, ctr, unique_ctr, unique_link_clicks_ctr, cpc, cpm, cpp, cost_per_total_action, cost_per_action_type, cost_per_unique_click, cost_per_10_sec_video_view, cost_per_unique_action_type, relevance_score, website_ctr, video_avg_sec_watched_actions, video_avg_pct_watched_actions, video_p25_watched_actions, video_p50_watched_actions, video_p75_watched_actions, video_p95_watched_actions, video_p100_watched_actions, video_complete_watched_actions, video_10_sec_watched_actions, video_15_sec_watched_actions, video_30_sec_watched_actions, estimated_ad_recallers, estimated_ad_recallers_lower_bound, estimated_ad_recallers_upper_bound, estimated_ad_recall_rate, estimated_ad_recall_rate_lower_bound, estimated_ad_recall_rate_upper_bound, cost_per_estimated_ad_recallers, canvas_avg_view_time, canvas_avg_view_percent, place_page_name, ad_bid_type, ad_bid_value, ad_delivery, adset_bid_type, adset_bid_value, adset_budget_type, adset_budget_value, adset_delivery, adset_start, adset_end

    adset_insights_columns = ['adset_id','impressions','spend','campaign_id']

    account_ids.each do |account_id|
      http_response = RestClient.get "#{BASE_URL}/#{account_id}/adsets",
                                      {:params => {'access_token' => ACCESS_TOKEN,
                                                   'fields' => adset_columns,
                                                   'limit' => 1000,
                                                   'date_preset' => 'lifetime'}}

      raw_data = JSON.parse(http_response)['data']

      raw_data.each do |adset|
        AdsetInsight.create(
          name:         adset['name'],
          adset_id:     adset['id'],
          account_id:   adset['account_id'],
          campaign_id:  adset['campaign_id'],
          status:       adset['status'],
          daily_budget: adset['daily_budget'],
          audience:     adset['name'].split('|')[3].strip
        )
      end
    end

    # Output Adset Insights Data
    puts "AdsetInsight Created: #{AdsetInsight.count}"
  end

  def self.build_ads
    Ad.delete_all
    AdAction.delete_all

    ad_columns = ['account_id','ad_id','ad_name','campaign_id','objective',
                  'impressions','spend','frequency','reach', 'actions',
                  'campaign_name', 'adset_id']

    account_ids.each do |account_id|
      ad_ids = JSON.parse(RestClient.get "#{BASE_URL}/#{account_id}/ads",
                                          {:params => {'access_token' => ACCESS_TOKEN,
                                                       'date_preset' =>
                                                       'lifetime'}})['data']

      ad_ids.each do |ad_id|
        http_response = RestClient.get "#{BASE_URL}/#{ad_id['id']}/insights",
                                        {:params => {'access_token' => ACCESS_TOKEN,
                                                     'fields' => ad_columns,
                                                     'date_preset' => 'lifetime',
                                                     'limit' => 1000,
                                                     'breakdowns' => 'placement'}}
        raw_data = JSON.parse(http_response)['data'].sort_by{|x| x[:name]}.reverse

        raw_data.each do |ad|
          Ad.create(
            account_id:    ad['account_id'],
            ad_id:         ad['ad_id'],
            adset_id:      ad['adset_id'],
            ad_name:       ad['ad_name'],
            campaign_id:   ad['campaign_id'],
            campaign_name: ad['campaign_name'],
            objective:     ad['objective'],
            impressions:   ad['impressions'],
            spend:         ad['spend'],
            frequency:     ad['frequency'],
            reach:         ad['reach'],
            placement:     ad['placement'],
            audience:      ad['campaign_name'].split('|')[1].strip
          )

          unless ad['actions'].nil? || ad['actions'].blank?
            ad['actions'].each do |action|
              AdAction.create(
                action_type:   action['action_type'],
                value:         action['value'],
                account_id:    ad['account_id'],
                campaign_id:   ad['campaign_id'],
                campaign_name: ad['campaign_name'],
                objective:     ad['objective'],
                placement:     ad['placement'],
                audience:      ad['campaign_name'].split('|')[1].strip
              )
            end
          end
        end
      end
    end

    # Output Ad and Ad Action Data
    puts "Ads Created: #{Ad.count}"
    puts "Ads Created: #{AdAction.count}"
  end

  private

  def self.account_ids
    ['act_1219094488105498','act_1219094361438844','act_1219093704772243','act_1219093848105562','act_1219093434772270']
  end

  def self.set_campaign_ids(account_id)
    campaign_ids = []

    http_response = RestClient.get "#{BASE_URL}/#{account_id}/campaigns",
                                    {:params => {'access_token' => ACCESS_TOKEN,
                                                 'date_preset' => 'lifetime'}}

    raw_data = JSON.parse(http_response)['data']

    raw_data.each do |data|
      campaign_ids.push(data)
    end

    return campaign_ids
  end
end
