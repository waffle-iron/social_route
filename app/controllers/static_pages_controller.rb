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

        impressions_daily = AccountInsight.where(account_id: 'act_1219093434772270').select(:date, :impressions).map{|k,v| {date: k[:date], impressions: k[:impressions]}}
        website_clicks_daily = AccountInsight.where(account_id: 'act_1219093434772270').select(:date, :website_clicks).map{|k,v| {date: k[:date], website_clicks: k[:website_clicks]}}
        video_views = Action.where(account_id: 'act_1219093434772270', action_type: 'video_view').map{|k,v| {date: k[:date], video_views: k[:value]}}
        post_engagements = Action.where(account_id: 'act_1219093434772270', action_type: 'post_engagement').map{|k,v| {date: k[:date], post_engagements: k[:value]}}

        daily_data = impressions_daily + website_clicks_daily + video_views + post_engagements
        daily_stats_data = daily_data.group_by{|h| h[:date]}.map{|k,v| v.reduce(:merge)}

        account_stats = {impressions: AccountInsight.where(account_id: 'act_1219093434772270').select(:impressions).sum(:impressions),
                         website_clicks: AccountInsight.where(account_id: 'act_1219093434772270').select(:website_clicks).sum(:website_clicks),
                         video_views: Action.where(account_id: 'act_1219093434772270', action_type: 'video_view').sum(:value),
                         post_engagement: Action.where(account_id: 'act_1219093434772270', action_type: 'post_engagement').sum(:value)
                       }

        render json: results_by_audience

        # render json: {date_range: "#{Date.parse(Action.where(account_id: 'act_1219093434772270').order('date').first.date).strftime("%b %e, %Y")} -
        #                            #{Date.parse(Action.where(account_id: 'act_1219093434772270').order('date').last.date).strftime("%b %e, %Y")}",
        #               overview: overview_stats,
        #               daily_stats_data: daily_stats_data,
        #               account_stats: account_stats,
        #               cpm_placement: cpm_by_placement,
        #               audiences: cpm_by_audience,
        #               demographics: age_gender_data
        #             }.to_json
      end
    end
  end

  def overview_stats
    data_source = Campaign.where(account_id:1219093434772270)
    result_data = AccountInsight.where(account_id: 'act_1219093434772270')

    impressions = data_source.group(:objective).sum(:impressions).map{|k,v| {objective: k, impressions: v}}
    reach = data_source.group(:objective).sum(:reach).map{|k,v| {objective: k, reach: v}}
    spend = data_source.group(:objective).sum(:spend).map{|k,v| {objective: k, spend: v}}

    results = [
      {objective: "CONVERSIONS",     results: Action.where(action_type: ["offsite_conversion.fb_pixel_purchase", "offsite_conversion.fb_pixel_view_content"]).sum(:value)},
      {objective: "LINK_CLICKS",     results: result_data.sum(:website_clicks)},
      {objective: "POST_ENGAGEMENT", results: Action.where(account_id: 'act_1219093434772270', action_type: 'video_view').sum(:value)},
      {objective: "VIDEO_VIEWS",     results: Action.where(account_id: 'act_1219093434772270', action_type: 'post_engagement').sum(:value)}
    ]

    combined_data = impressions + reach + spend + results

    return combined_data.group_by{|h| h[:objective]}.map{|k,v| v.reduce(:merge)}
  end

  def cpm_by_placement
    data = []
    placements = [{name: 'Desktop News Feed', columns: ['desktop_feed', 'desktop_video_channel']},
                  {name: 'Mobile News Feed', columns: ['mobile_feed', 'mobile_video_channel']},
                  {name: 'Desktop Right Column', columns: 'right_hand'},
                  {name: 'Instragram', columns: 'instagramstream'},
                  {name: 'Audience Network', columns: 'mobile_external_only'}]

    placements.each do |placement|
      impressions = Ad.where(account_id:1219093434772270, placement: placement[:columns]).sum(:impressions).to_f
      spend = Ad.where(account_id:1219093434772270, placement: placement[:columns]).sum(:spend)

      data.push(placement: placement[:name], cpm: spend/(impressions/1000))
    end

    return data
  end

  def cpm_by_audience
    audiences = []

    objectives = Campaign.where(account_id:1219093434772270).pluck('objective').uniq

    objectives.each do |objective|
      impressions = Campaign.where(account_id:1219093434772270, objective: objective).group(:name, :objective).sum(:impressions).map{|k,v| {audience: k[0].split('|')[1].strip, impressions: v}}
      spend = Campaign.where(account_id:1219093434772270, objective: objective).group(:name, :objective).sum(:spend).map{|k,v| {audience: k[0].split('|')[1].strip, spend: v}}
      combined_data = impressions + spend

      audiences.push(objective: objective_name(objective), audiences: combined_data.group_by{|h| h[:audience]}.map{|k,v| v.reduce(:merge)})
    end

    return audiences
  end

  def results_by_audience
    general_breakdowns = Array.new
    audiences = Array.new

    Campaign.where(account_id:1219093434772270).group(:name)

    Campaign.where(account_id:1219093434772270).pluck(:name).each do |audience|
      audiences.push(audience.split('|')[1].strip)
    end

    uniq_audiences = audiences.uniq!

    uniq_audiences.each do |audience|
      general_breakdowns.push(audience: audience, results: '1')
    end

    return general_breakdowns


    # general_breakdowns = []
    #
    # Campaign.where(account_id:1219093434772270).group(:name).sum(:total_actions).each do |account_insight|
    #   general_breakdowns.push(audience: account_insight[0].split('|')[1].strip, results: account_insight[1])
    # end
    #
    # age_breakdowns = []
    #
    # AccountInsight.where(account_id: 'act_1219093434772270').where.not(age: nil).each do |account_insight|
    #   age_breakdowns.push(account_insight)
    # end
    #
    # gender_breakdowns = []
    #
    # AccountInsight.where(account_id: 'act_1219093434772270').where.not(gender: nil).each do |account_insight|
    #   gender_breakdowns.push(account_insight)
    # end
    # Action.where(account_id: 'act_1219093434772270', action_type: 'post_engagement').all
  end

  def objective_name(objective)
    case objective
    when "LINK_CLICKS"
      "Clicks to Website"
    when "POST_ENGAGEMENT"
      "Post Engagement"
    when "VIDEO_VIEWS"
      "Video Views"
    when "CONVERSIONS"
      "Website Conversions"
    else
      objective
    end
  end
end
