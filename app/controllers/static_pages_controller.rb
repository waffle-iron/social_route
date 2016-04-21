class StaticPagesController < ApplicationController
  require 'rest-client'
  BASE_URL = 'https://graph.facebook.com/v2.6/'
  AD_ACCOUNT_ID = '1219093434772270'
  ACCESS_TOKEN = 'CAANNAsbKK4kBAIauk7N9xmJf26DEJPvwxU6cMePLMpJ4Gh81UeiDm7PAaOMGhNWqI8KZB1ZBXu7VdEtnnWFgXwg5CmzsUyWUghgRMZCLR241aqafzXcYFQZANUgBbZBHtbVCik2T5HhlZCL1sq74qDvyfKhUup9VXQzrgLLRq7NtQJoHUp2QQy8jjASXYabnLaQByZCg9vxypRb7w7YRZCJq'
  FIELDS = ['name']

  # accounts = Net::HTTP.get(URI.parse("https://graph.facebook.com/v2.5/10152789234082798/adaccounts?access_token=#{ACCESS_TOKEN}"))

  # adsets = Net::HTTP.get(URI.parse("https://graph.facebook.com/v2.5/act_#{AD_ACCOUNT_ID}/adsets?access_token=#{ACCESS_TOKEN}"))

  # account_insights = Net::HTTP.get(URI.parse("https://graph.facebook.com/v2.5/act_#{AD_ACCOUNT_ID}/insights?access_token=#{ACCESS_TOKEN}"))

  # campaigns = Net::HTTP.get(URI.parse("https://graph.facebook.com/v2.5/act_#{AD_ACCOUNT_ID}/campaigns/?access_token=#{ACCESS_TOKEN}&fields=#{FIELDS}"))

  def dashboard
    campaigns = RestClient.get "#{BASE_URL}/act_#{AD_ACCOUNT_ID}/campaigns", {:params => {:access_token => ACCESS_TOKEN, 'fields' => FIELDS}}

    @campaigns = JSON.parse(campaigns)['data']

    @adaccounts = adaccounts

    # data = eval(@campaigns)[:data]

    #
    # @accounts = ['Denver Museum of Nature & Science']


    @campaigns.each do |campaign|
      puts campaign[:name]
    end
  end

  def account_overview

  end

  private

  def adaccounts
    raw_data = RestClient.get "#{BASE_URL}/me/adaccounts", {:params => {:access_token => ACCESS_TOKEN, 'fields' => ['name', 'account_status']}}
    JSON.parse(raw_data)['data'].sort_by{|x| x[:name]}.reverse
  end
end
