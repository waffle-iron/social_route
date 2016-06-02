class StaticPagesController < ApplicationController
  before_action :set_account

  def dashboard
  end

  def overview
  end

  def adset_overview
  end

  def reporting
  end

  private

  def set_account
     @account = Account.find_by_account_id(params['account_id'])
  end
end
