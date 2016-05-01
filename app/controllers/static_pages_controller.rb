class StaticPagesController < ApplicationController
  require 'rest-client'
  BASE_URL = 'https://graph.facebook.com/v2.6/'
  AD_ACCOUNT_ID = '1219093434772270'
  ACCESS_TOKEN = 'EAANNAsbKK4kBAClSAtcltIwvAZCMNSb6kvE69zfV6ld1ENFUh2wUtY7nTXK5ZAdAzmhOsftZAmEUMRTrsHzkMMTpOGTj9MtQnIjzsA471paMeg7cgA9GCw9fBOmDMJ3FpOOXefY66PZAJFvGh8CsZBkJnlTOIqArla7ExvZAHx0AZDZD'

  def dashboard
    @adaccounts = Account.all
  end

  def overview
    @account_name = params['account_name']
    account = account_data(params['account_id'])
  end

  def reporting
    @account = Account.find_by_account_id(params['account_id'])

    respond_to do |format|
      format.html
      format.json do
        impressions = Ad.where(account_id:1219093434772270).group(:objective).sum(:impressions).map{|k,v| {objective: k, impressions: v}}
        reach = Ad.where(account_id:1219093434772270).group(:objective).sum(:reach).map{|k,v| {objective: k, reach: v}}
        total_actions = Ad.where(account_id:1219093434772270).group(:objective).sum(:total_actions).map{|k,v| {objective: k, total_actions: v}}

        final_data = impressions + reach + total_actions
        json_data = final_data.group_by{|h| h[:objective]}.map{|k,v| v.reduce(:merge)}

        placement = Campaign.where(account_id:1219093434772270).group(:placement).sum(:cpm).map{|k,v| {placement: k, cpm: v}}

        audiences = []

        Campaign.where(account_id:1219093434772270).group(:name, :objective).average(:cpm).each do |group|
          audiences.push(objective: group[0][1], audience: group[0][0].split('|')[1].strip, cpm: group[1])
        end

        render json: {overview: json_data, cpm_placement: placement, audiences: audiences, demographics: 'demographics'}.to_json
      end
    end
  end

  private

  def adaccounts
    raw_data = RestClient.get "#{BASE_URL}/me/adaccounts", {:params => {:access_token => ACCESS_TOKEN, 'fields' => ['name', 'account_status']}}
    JSON.parse(raw_data)['data'].sort_by{|x| x[:name]}.reverse
  end

  def account_data(account_id)
    @account_data = []
    campaigns = RestClient.get "#{BASE_URL}/#{account_id}/campaigns", {:params => {:access_token => ACCESS_TOKEN, 'fields' => ['name']}}
    campaigns = JSON.parse(campaigns)['data'].sort_by{|x| x[:name]}.reverse

    campaigns.each do |campaign|
      @account_data.push(campaign)
    end
  end
end
