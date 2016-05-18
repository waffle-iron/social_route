class StaticPagesController < ApplicationController
  before_action :require_login
  
  def dashboard
  end

  def overview
    @account = Account.find_by_account_id(params['account_id'])
  end

  def overview_adsets
    @campaign = Campaign.find_by_campaign_id(params['campaign_id'])
  end

  def reporting
    @account = Account.find_by_account_id(params['account_id'])
  end
end
