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

        data = []

        impressions_daily = AccountInsight.where(account_id: 'act_1219093434772270').group(:impressions).map{|k,v| {date: k, impressions: v}}
        website_clicks_daily = AccountInsight.where(account_id: 'act_1219093434772270').group(:website_clicks).map{|k,v| {date: k, website_clicks: v}}
        daily_data = impressions_daily + website_clicks_daily
        daily_stats_data = daily_data.group_by{|h| h[:date]}.map{|k,v| v.reduce(:merge)}

        # daily_stats_data = {
        #                     website_clicks:
        #                     video_views: Action.where(account_id: 'act_1219093434772270', action_type: 'video_view'),
        #                     post_engagement: Action.where(account_id: 'act_1219093434772270', action_type: 'post_engagement')
        #                    }

        account_stats = {impressions: AccountInsight.where(account_id: 'act_1219093434772270').select(:impressions).sum(:impressions),
                         website_clicks: AccountInsight.where(account_id: 'act_1219093434772270').select(:website_clicks).sum(:website_clicks),
                         video_views: Action.where(account_id: 'act_1219093434772270', action_type: 'video_view').sum(:value),
                         post_engagement: Action.where(account_id: 'act_1219093434772270', action_type: 'post_engagement').sum(:value)
                       }



        placement = Campaign.where(account_id:1219093434772270).group(:placement).sum(:cpm).map{|k,v| {placement: k, cpm: v}}

        audiences = []

        Campaign.where(account_id:1219093434772270).group(:name, :objective).average(:cpm).each do |group|
          audiences.push(objective: group[0][1], audience: group[0][0].split('|')[1].strip, cpm: group[1])
        end

        general_breakdowns = []

        Campaign.where(account_id:1219093434772270).group(:name).sum(:total_actions).each do |account_insight|
          general_breakdowns.push(audience: account_insight[0].split('|')[1].strip, results: account_insight[1])
        end

        age_breakdowns = []

        AccountInsight.where(account_id: 'act_1219093434772270').where.not(age: nil).each do |account_insight|
          age_breakdowns.push(account_insight)
        end

        gender_breakdowns = []

        AccountInsight.where(account_id: 'act_1219093434772270').where.not(gender: nil).each do |account_insight|
          gender_breakdowns.push(account_insight)
        end

        render json: {overview: json_data,
                      dailyStatsData: daily_stats_data,
                      account_stats: account_stats,
                      cpm_placement: placement,
                      audiences: audiences,
                      demographics: {
                        general_breakdowns: general_breakdowns,
                        age_breakdowns:     age_breakdowns,
                        gender_breakdowns:  gender_breakdowns
                      }
                    }.to_json
      end
    end
  end
end
