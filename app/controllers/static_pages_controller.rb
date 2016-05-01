class StaticPagesController < ApplicationController
  def dashboard
    respond_to do |format|
      format.html
      format.json do
        render json: Account.all.to_json
      end
    end
  end

  def overview
    @account = Account.find_by_account_id(params['account_id'])
    respond_to do |format|
      format.html
      format.json do
        render json: 'Cat'
      end
    end
  end

  def reporting
    @account = Account.find_by_account_id(params['account_id'])

    respond_to do |format|
      format.html
      format.json do
        impressions = Ad.where(account_id:1219093434772270).group(:objective).sum(:impressions).map{|k,v| {objective: k, impressions: v}}
        reach = Ad.where(account_id:1219093434772270).group(:objective).sum(:reach).map{|k,v| {objective: k, reach: v}}
        total_actions = Ad.where(account_id:1219093434772270).group(:objective).sum(:total_actions).map{|k,v| {objective: k, total_actions: v}}
        spend = Ad.where(account_id:1219093434772270).group(:objective).sum(:spend).map{|k,v| {objective: k, spend: v}}

        final_data = impressions + reach + total_actions + spend
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
end
