class StaticPagesController < ApplicationController
  include ActionView::Helpers::NumberHelper
  before_action :set_account_params

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

        # render json: cpr_by_audience
        render json: {date_range: "#{Date.parse(Action.where(account_id: @account_id).order('date').first.date).strftime("%b %e, %Y")} -
                                   #{Date.parse(Action.where(account_id: @account_id).order('date').last.date).strftime("%b %e, %Y")}",
                      overview: overview_stats,
                      account_stats: account_stats,
                      cpm_cpr_placement: cpm_cpr_by_placement,
                      audiences: cpm_by_audience,
                      audiences_cpr: cpr_by_audience,
                      demographics: {gender_breakdowns: gender_demographics,
                                     age_breakdowns: age_demographics,
                                     audience_breakdowns: audience_demographics}
                    }.to_json
      end
    end
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

    # return combined_data.group_by{|h| h[:objective]}.map{|k,v| v.reduce(:merge)}
    return raw_data
  end


  def gender_demographics
    gender_breakdowns = Array.new
    genders = ['male', 'female', 'unkown']
    columns = ['video_view', 'offsite_conversion', 'comment', 'post', 'post_like', 'like', 'link_click']
    gender_sum = Action.where(account_id: @account_id, action_type: columns, gender: [genders]).sum(:value)

    genders.each do |gender|
      results = Action.where(account_id: @account_id, action_type: columns, gender: gender).sum(:value)
      percentage = ((results/gender_sum)*100).round(1)

      gender_breakdowns.push({gender: gender.capitalize, gender_with_data: "#{gender.capitalize}: #{percentage}%",
                              results: results})
    end

    return gender_breakdowns
  end

  def age_demographics
    age_breakdowns = Array.new
    ages = Action.pluck('age').compact.uniq
    columns = ['video_view', 'offsite_conversion', 'comment', 'post', 'post_like', 'like', 'link_click']
    age_sum = Action.where(account_id: @account_id, action_type: columns, age: [ages]).sum(:value)

    ages.each do |age|
      results = Action.where(account_id: @account_id, action_type: columns, age: age).sum(:value)

      percentage = ((results/age_sum)*100).round(1)

      age_breakdowns.push({age: age, age_with_data: "#{age}: #{percentage}%",
                           results: results})
    end

    return age_breakdowns
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

  private

  def set_account_params
    # flash[:success] = params['act_id']
    @account_id = 'act_1219094488105498'
    @account_id_number = '1219094488105498'
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
end
