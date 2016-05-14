class ApiController < ApplicationController
  include ActionView::Helpers::NumberHelper
  before_action :set_account_params

  def dashboard
    render json: Account.where(account_id: ['act_1219094488105498','act_1219094361438844','act_1219093704772243','act_1219093848105562','act_1219093434772270'])
  end

  def overview
    render json: campaign_data
  end

  def overview_adets
    render json: adset_data
  end

  def reporting
    impressions = Ad.where(account_id: @account_id_number).group(:objective).sum(:impressions).map{|k,v| {objective: k, impressions: v}}
    reach = Ad.where(account_id: @account_id_number).group(:objective).sum(:reach).map{|k,v| {objective: k, reach: v}}
    spend = Ad.where(account_id: @account_id_number).group(:objective).sum(:spend).map{|k,v| {objective: k, spend: v}}

    final_data = impressions + reach + spend
    json_data = final_data.group_by{|h| h[:objective]}.map{|k,v| v.reduce(:merge)}

    data = []

    account_stats = {impressions: AccountInsight.where(account_id: @account_id).select(:impressions).sum(:impressions),
                     website_clicks: Action.where(account_id: @account_id, action_type: 'link_click', gender: nil, age: nil).sum(:value),
                     website_conversions: Action.where(account_id: @account_id, action_type: 'offsite_conversion', gender: nil, age: nil).sum(:value),
                     video_views: Action.where(account_id: @account_id, action_type: 'video_view', gender: nil, age: nil).sum(:value),
                     post_engagement: Action.where(account_id: @account_id, action_type: ['comment', 'post', 'post_like', 'like'], gender: nil, age: nil).sum(:value)
                   }

    render json: {date_range: "#{Date.parse(Action.where(account_id: @account_id).order('date').first.date).strftime("%b %e, %Y")} -
                               #{Date.parse(Action.where(account_id: @account_id).order('date').last.date).strftime("%b %e, %Y")}",
                  overview: overview_stats,
                  account_stats: account_stats,
                  cpm_cpr_placement: cpm_cpr_by_placement,
                  audiences: cpm_by_audience,
                  audiences_cpr: cpr_by_audience,
                  demographics: {age_and_gender: age_and_gender,
                                 audience_breakdowns: audience_demographics}
                }
  end

  def overview_stats
    impressions = Campaign.where(account_id: @account_id_number).group(:objective).sum(:impressions).map{|k,v| {objective: k, impressions: v}}
    reach = Campaign.where(account_id: @account_id_number).group(:objective).sum(:reach).map{|k,v| {objective: k, reach: v}}
    spend = Campaign.where(account_id: @account_id_number).group(:objective).sum(:spend).map{|k,v| {objective: k, spend: v}}

    results = [
      {objective: "CONVERSIONS",     results: CampaignAction.where(account_id: @account_id_number, objective: 'CONVERSIONS', action_type: "offsite_conversion").sum(:value)},
      {objective: "LINK_CLICKS",     results: CampaignAction.where(account_id: @account_id_number, objective: 'LINK_CLICKS', action_type: "link_click").sum(:value)},
      {objective: "POST_ENGAGEMENT", results: CampaignAction.where(account_id: @account_id_number, objective: 'POST_ENGAGEMENT', action_type: "post_engagement").sum(:value)},
      {objective: "VIDEO_VIEWS",     results: Action.where(account_id: @account_id, action_type: 'video_view',  gender: nil, age: nil).sum(:value)}
    ]

    #Calculate VV by CampaignAction?

    combined_data = impressions + reach + spend + results

    return combined_data.group_by{|h| h[:objective]}.map{|k,v| v.reduce(:merge)}
  end

  def cpm_cpr_by_placement
    data = []
    result_columns = ['video_view', 'offsite_conversion', 'comment', 'post', 'post_like', 'like', 'link_click']

    placements = [{name: 'Desktop News Feed',    placement_columns: ['desktop_feed', 'desktop_video_channel']},
                  {name: 'Mobile News Feed',     placement_columns: ['mobile_feed', 'mobile_video_channel']},
                  {name: 'Desktop Right Column', placement_columns: 'right_hand'},
                  {name: 'Instragram',           placement_columns: 'instagramstream'},
                  {name: 'Audience Network',     placement_columns: 'mobile_external_only'}]

    placements.each do |placement|
      impressions = Ad.where(account_id:@account_id_number, placement: placement[:placement_columns]).sum(:impressions).to_f
      results     = AdAction.where(account_id:@account_id_number, placement: placement[:placement_columns], action_type: result_columns).sum(:value).to_f
      spend       = Ad.where(account_id:@account_id_number, placement: placement[:placement_columns]).sum(:spend)

      data.push(placement: placement[:name], cpr: spend/results, cpm: spend/(impressions/1000))
    end

    return data
  end

  def cpm_by_audience
    audiences = []

    objectives = Campaign.where(account_id:@account_id_number).pluck('objective').uniq

    objectives.each do |objective|
      impressions = Campaign.where(account_id:@account_id_number, objective: objective).group(:name, :objective).sum(:impressions).map{|k,v| {audience: k[0].split('|')[1].strip, impressions: v}}
      spend = Campaign.where(account_id:@account_id_number, objective: objective).group(:name, :objective).sum(:spend).map{|k,v| {audience: k[0].split('|')[1].strip, spend: v}}
      combined_data = impressions + spend

      audiences.push(objective: objective_name(objective), audiences: combined_data.group_by{|h| h[:audience]}.map{|k,v| v.reduce(:merge)})
    end

    return audiences

    # Pull with CampaignAction
  end

  def cpr_by_audience
    raw_data = []
    audience_name_and_spend = Campaign.where(account_id:@account_id_number).group(:objective, :audience).sum(:spend)

    audience_name_and_spend.each do |data|
      if data[0][0] == "CONVERSIONS"
        results = CampaignAction.where(account_id: @account_id_number, objective: 'CONVERSIONS', action_type: "offsite_conversion", audience: data[0][1]).sum(:value)
      elsif data[0][0] == "LINK_CLICKS"
        results = CampaignAction.where(account_id: @account_id_number, objective: 'LINK_CLICKS', action_type: "link_click", audience: data[0][1]).sum(:value)
      elsif data[0][0] == "POST_ENGAGEMENT"
        results = CampaignAction.where(account_id: @account_id_number, objective: 'POST_ENGAGEMENT', action_type: "post_engagement", audience: data[0][1]).sum(:value)
      elsif data[0][0] == "VIDEO_VIEWS"
        results = CampaignAction.where(account_id: @account_id_number, objective: 'VIDEO_VIEWS', action_type: "video_view", audience: data[0][1]).sum(:value)
      end

      raw_data.push(objective: data[0][0], audience: data[0][1], spend: data[1], results:results, cpr: data[1]/results.to_f)
    end

    return raw_data
  end

  def age_and_gender
    age_and_gender_breakdowns = Array.new
    ages = ['13-17', '18-24', '25-34', '45-54', '55-64', '65+']
    age_and_gender_columns = ['video_view', 'offsite_conversion', 'comment',
                              'post', 'post_like', 'like', 'link_click']

    ages.each do |age|
      male_results = Action.where(account_id: @account_id, action_type: age_and_gender_columns, gender: ['male', 'unkown']).sum(:value)
      female_results = Action.where(account_id: @account_id, action_type: age_and_gender_columns, gender: 'female').sum(:value)
      male_age_results = Action.where(account_id: @account_id, action_type: age_and_gender_columns, age: age, gender: ['male', 'unkown']).sum(:value)
      female_age_results = Action.where(account_id: @account_id, action_type: age_and_gender_columns, age: age, gender: 'female').sum(:value)

      age_and_gender_breakdowns.push(age: age, male_results: male_age_results/male_results, female_results: female_age_results/female_results)
    end

    return age_and_gender_breakdowns
  end

  def audience_demographics
    audience_demographics = Array.new
    audiences = CampaignAction.where(account_id: @account_id_number).pluck('audience').uniq
    columns = ['video_view', 'offsite_conversion', 'comment', 'post', 'post_like', 'like', 'link_click']
    total_results = CampaignAction.where(account_id: @account_id_number, action_type: columns).sum(:value)
    cleaned_audiences = Array.new

    audiences.each do |audience|
      results = CampaignAction.where(account_id: @account_id_number, action_type: columns, audience: audience).sum(:value)
      percentage = (results/total_results)*100

      if percentage >= 1
        cleaned_audiences.push(audience)
      end
    end

    cleaned_audiences.each do |audience|
      spend = CampaignInsight.where(account_id: @account_id_number, audience: audience).sum(:spend)
      results = CampaignAction.where(account_id: @account_id_number, action_type: columns, audience: audience).sum(:value)
      impressions = CampaignInsight.where(account_id: @account_id_number, audience: audience).sum(:impressions).to_f

      audience_demographics.push(audience: audience, results: results, cpm: spend/(impressions/1000))
    end

    return audience_demographics
  end

  def campaign_data
    puts 'PARAMS'.colorize(:green)
    puts params[:account_id]

    raw_data = Array.new
    objectives = Campaign.where(account_id:@account_id_number).pluck('objective').uniq

    objectives.each do |objective|
      campaign_data = Array.new
      campaigns = CampaignInsight.where(account_id:@account_id_number, objective: objective)

      campaigns.each do |campaign|
        results = CampaignAction.where(campaign_id: campaign.campaign_id, action_type: result_columns(campaign.objective)).sum(:value)
        rr = (results/campaign.impressions.to_f)*100
        cpm = campaign.spend/(campaign.impressions.to_f/1000)
        score = cpm * (1/rr)

        campaign_data.push(campaign_id: campaign.campaign_id,
                           campaign_name: campaign.campaign_name,
                           rr:            rr,
                           impressions:   campaign.impressions,
                           cpm:           cpm,
                           spend:         campaign.spend,
                           score:         score)
      end

      raw_data.push(objective: objective_name(objective), campaign_data: campaign_data)
    end

    return raw_data
  end

  def adset_data
    raw_data = Array.new

    adsets = Adset.where(campaign_id: params['campaign_id'])

    adsets.each do |adset|
      adset_insight = AdsetInsight.where(adset_id: adset.adset_id)

      results = AdsetInsight.where(adset_id: adset.adset_id, action_type: result_columns(adset.objective)).sum(:value)

      raw_data.push(adsets: {name: adset.name,
                             adset_id: adset.adset_id,
                             account_id: adset.account_id,
                             campaign_id: adset.campaign_id,
                             status: adset.status,
                             daily_budget: adset.daily_budget/100,
                             audience: adset.audience,
                             impressions: adset_insight.sum(:impressions),
                             spend: adset_insight.sum(:spend),
                             frequency: adset_insight.average(:frequency),
                             cpm: adset_insight.sum(:spend)/(adset_insight.sum(:impressions).to_f/1000),
                             cpr: adset_insight.sum(:spend)/(results)
                             })
    end

    return raw_data.push(budget_active: Adset.where(campaign_id: params['campaign_id'], status: 'ACTIVE').sum(:daily_budget)/100,
                         budget_paused: Adset.where(campaign_id: params['campaign_id'], status: 'PAUSED').sum(:daily_budget)/100,
                         budget_total: Adset.where(campaign_id: params['campaign_id']).sum(:daily_budget)/100)
  end

  private

  def set_account_params
    @account_id = params['account_id']
    @account_id_number = params['account_id'].to_s[4..-1]
    # params['account_id'].to_s[4..-1]
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

  def result_columns(objective)
    case objective
    when "LINK_CLICKS"
      ['link_click']
    when "POST_ENGAGEMENT"
      ['comment', 'post', 'post_like', 'like']
    when "VIDEO_VIEWS"
      ['video_view']
    when "CONVERSIONS"
      ['offsite_conversion']
    end
  end
end
