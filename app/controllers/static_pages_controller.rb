class StaticPagesController < ApplicationController
  require 'rest-client'
  BASE_URL = 'https://graph.facebook.com/v2.6/'
  AD_ACCOUNT_ID = '1219093434772270'
  ACCESS_TOKEN = 'EAANNAsbKK4kBADrVIt4y2bCl39ZCZBUGJc3CPofeIqZCa4CW0brSnz4GRzZBQZAMzZBOR77vllunzB4cQpwalB6ZBW8hIe2H8ZAojdbmNiaoQC14XBtqIe7oIYweadOd9aCcNb87ZCZCtmUivbyHd23cyMNHHGmVpV3eUV2DegTWmljgZDZD'

  # accounts = Net::HTTP.get(URI.parse("https://graph.facebook.com/v2.5/10152789234082798/adaccounts?access_token=#{ACCESS_TOKEN}"))

  adsets = Net::HTTP.get(URI.parse("https://graph.facebook.com/v2.5/act_#{AD_ACCOUNT_ID}/adsets?access_token=#{ACCESS_TOKEN}&fields=['name']"))
  # account_insights = Net::HTTP.get(URI.parse("https://graph.facebook.com/v2.5/act_#{AD_ACCOUNT_ID}/insights?access_token=#{ACCESS_TOKEN}"))

  # campaigns = Net::HTTP.get(URI.parse("https://graph.facebook.com/v2.5/act_#{AD_ACCOUNT_ID}/campaigns/?access_token=#{ACCESS_TOKEN}&fields=#{FIELDS}"))

  def dashboard
    @adaccounts = Account.all
  end

  def overview
    @account_name = params['account_name']
    account = account_data(params['account_id'])
  end

  def reporting
    @account = Account.find_by_account_id(params['account_id'])
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
