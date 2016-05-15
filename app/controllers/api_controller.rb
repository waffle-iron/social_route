class ApiController < ApplicationController
  include ActionView::Helpers::NumberHelper
  before_action :set_account_params

  def dashboard
    render json: Account.where(account_id: ['act_1219094488105498','act_1219094361438844','act_1219093704772243','act_1219093848105562','act_1219093434772270'])
    require "prawn"


  end

  def overview
    render json: campaign_data
  end

  def overview_adets
    render json: adset_data
  end

  def reporting
    respond_to do |format|
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

        render json: {date_range: @dates,
                      overview: overview_stats,
                      account_stats: account_stats,
                      cpm_cpr_placement: cpm_by_placement,
                      audiences: cpm_by_audience,
                      audiences_cpr: cpr_by_audience,
                      demographics: {age_and_gender: age_and_gender,
                                     audience_breakdowns: audience_demographics},
                      ad_formats: ad_formats,
                      ad_data: ad_data,
                      targeting: targeting
                    }
      end

      format.pdf { build_pdf }
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

  def cpm_by_placement
    data = []
    result_columns = ['video_view', 'offsite_conversion', 'comment', 'post', 'post_like', 'like', 'link_click']

    placements = [{name: 'Desktop News Feed',    placement_columns: ['desktop_feed', 'desktop_video_channel']},
                  {name: 'Mobile News Feed',     placement_columns: ['mobile_feed', 'mobile_video_channel']},
                  {name: 'Desktop Right Column', placement_columns: 'right_hand'},
                  {name: 'Instragram',           placement_columns: 'instagramstream'},
                  {name: 'Audience Network',     placement_columns: 'mobile_external_only'}]

    placements.each do |placement|
      impressions = Ad.where(account_id:@account_id_number, placement: placement[:placement_columns]).sum(:impressions).to_f
      spend       = Ad.where(account_id:@account_id_number, placement: placement[:placement_columns]).sum(:spend)

      data.push(placement: placement[:name], cpm: spend/(impressions/1000))
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

  def ad_formats
    final_data = Array.new

    impressions = Ad.where(account_id: @account_id_number).group(:format).sum(:impressions).map{|k,v| {format: k, impressions: v}}
    spend = Ad.where(account_id: @account_id_number).group(:format).sum(:spend).map{|k,v| {format: k, spend: v}}

    raw_data = impressions + spend
    json_data = raw_data.group_by{|h| h[:format]}.map{|k,v| v.reduce(:merge)}

    json_data.each do |data|
      final_data.push(format: data[:format], cpm: data[:spend]/(data[:impressions].to_f/1000))
    end

    return final_data
  end

  def ad_data
    final_data = Array.new

    impressions = Ad.where(account_id: @account_id_number).group(:simple_name).sum(:impressions).map{|k,v| {simple_name: k, impressions: v}}
    spend = Ad.where(account_id: @account_id_number).group(:simple_name).sum(:spend).map{|k,v| {simple_name: k, spend: v}}

    raw_data = impressions + spend
    json_data = raw_data.group_by{|h| h[:simple_name]}.map{|k,v| v.reduce(:merge)}

    json_data.each do |data|
      final_data.push(simple_name: data[:simple_name], cpm: data[:spend]/(data[:impressions].to_f/1000))
    end

    return final_data
  end

  def targeting
    target_data = Array.new

    audiences = Adset.where(account_id: @account_id_number).pluck('audience').uniq
    audiences.each do |audience|
      ad_target = AdsetTargeting.where(audience: audience, account_id:  @account_id_number).last

      target_data.push(name: "Audience: #{audience}",
                       audience: audience,
                       min_age: ad_target.age_min,
                       max_age: ad_target.age_max,
                       geolocations: Adset.where(audience: audience, account_id: @account_id_number).last.targeting)
    end

    return target_data
  end

  def build_pdf
    @account = Account.find_by_account_id(params['account_id'])
    @dates = "#{Date.parse(Action.where(account_id: @account_id).order('date').first.date).strftime("%B %e, %Y")} - #{Date.parse(Action.where(account_id: @account_id).order('date').last.date).strftime("%b %e, %Y")}"


    pdf = ReportPdf.new(@account.name,
                        @dates,
                        campaign_overview_pdf,
                        campaign_objectives_overview_pdf,
                        cpm_by_placement_pdf,
                        cpm_by_audience_and_objective_pdf,
                        results_by_age_and_gender_pdf,
                        results_by_audience_pdf,
                        cpm_by_audience_pdf)

    send_data pdf.render, filename: "#{@account.name}.pdf",
                          type: "application/pdf",
                          disposition: "inline"
  end

  def campaign_overview_pdf
    campaign_overview = Array.new

    impressions = AccountInsight.where(account_id: @account_id).select(:impressions).sum(:impressions).to_f
    website_clicks = Action.where(account_id: @account_id, action_type: 'link_click', gender: nil, age: nil).sum(:value)
    website_conversions = Action.where(account_id: @account_id, action_type: 'offsite_conversion', gender: nil, age: nil).sum(:value)
    post_engagement = Action.where(account_id: @account_id, action_type: 'video_view', gender: nil, age: nil).sum(:value)
    video_views = Action.where(account_id: @account_id, action_type: ['comment', 'post', 'post_like', 'like'], gender: nil, age: nil).sum(:value)

    if impressions > 0
      campaign_overview.push(['Impressions'.upcase, number_with_delimiter(impressions.round(0), delimiter: ',') ])
    end

    if website_clicks > 0
      campaign_overview.push(['Website Clicks'.upcase, number_with_delimiter(website_clicks.round(0), delimiter: ',') ])
    end

    if website_conversions > 0
      campaign_overview.push(['Website Conversions'.upcase, number_with_delimiter(website_conversions.round(0), delimiter: ',') ])
    end

    if post_engagement > 0
      campaign_overview.push(['Likes, Comments, & Shares'.upcase, number_with_delimiter(post_engagement.round(0), delimiter: ',') ])
    end

    if video_views > 0
      campaign_overview.push(['Video Views'.upcase, number_with_delimiter(video_views.round(0), delimiter: ',') ])
    end

    return campaign_overview
  end

  def campaign_objectives_overview_pdf
    campaign_objectives_overview = [['Campaign Objective', 'Results', 'CPR', 'Reach', 'Impressions', 'CPM']]

    overview_stats.each do |objective_data|
      cpr = number_to_currency(objective_data[:spend]/objective_data[:results].to_f)
      cpm = number_to_currency(objective_data[:spend]/(objective_data[:impressions].to_f/1000))

      campaign_objectives_overview.push([objective_name(objective_data[:objective]),
                                        number_with_delimiter(objective_data[:results].round(0), delimiter: ','),
                                        cpr,
                                        number_with_delimiter(objective_data[:reach].round(0), delimiter: ','),
                                        number_with_delimiter(objective_data[:impressions].to_f.round(0), delimiter: ','),
                                        cpm])
    end

    return campaign_objectives_overview
  end

  def cpm_by_placement_pdf
    return cpm_by_placement.map { |data| [data[:placement], data[:cpm]]}.to_h
  end

  def cpm_by_audience_and_objective_pdf
    cpm_by_audience_and_objective = Hash.new
    audiences = Campaign.where(account_id: @account_id_number).pluck('audience').uniq

    audiences.each do |audience|
      cpm_by_audience_and_objective.merge!({"#{audience} Audience".to_s.to_sym =>
                                           {'Clicks to Website' => calculate_cpm('LINK_CLICKS', audience),
                                            'Post Engagement' => calculate_cpm('POST_ENGAGEMENT', audience),
                                            'Video Views' => calculate_cpm('VIDEO_VIEWS', audience),
                                            'Website Conversions' => calculate_cpm('CONVERSIONS', audience)}})
    end

    return cpm_by_audience_and_objective
  end

  def results_by_age_and_gender_pdf
    results_by_age_and_gender = Array.new

    age_and_gender_columns = ['video_view', 'offsite_conversion', 'comment',
                              'post', 'post_like', 'like', 'link_click']

    male_results = Action.where(account_id: @account_id, action_type: age_and_gender_columns, gender: ['male', 'unkown']).sum(:value)
    female_results = Action.where(account_id: @account_id, action_type: age_and_gender_columns, gender: 'female').sum(:value)
    total_results = Action.where(account_id: @account_id, action_type: age_and_gender_columns).sum(:value)

    results_by_age_and_gender.push(((male_results/total_results)*100).round(0))
    results_by_age_and_gender.push(((female_results/total_results)*100).round(0))
    results_by_age_and_gender.push(age_and_gender.map { |data| [data[:age], (data[:male_results]*100).round(1)]}.to_h)
    results_by_age_and_gender.push(age_and_gender.map { |data| [data[:age], (data[:female_results]*100).round(1)]}.to_h)

    return results_by_age_and_gender
  end

  def results_by_audience_pdf
    return audience_demographics.map { |data| [data[:audience], data[:results]]}.to_h
  end

  def cpm_by_audience_pdf
    return audience_demographics.map { |data| [data[:audience], data[:cpm]]}.to_h
  end

  private

  def set_account_params
    @account_id = params['account_id']
    @account_id_number = params['account_id'].to_s[4..-1]
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

  def calculate_cpm(objective, audience)
    impressions = Campaign.where(account_id:@account_id_number, objective: objective, audience: audience).sum(:impressions).to_f
    spend = Campaign.where(account_id:@account_id_number, objective: objective, audience: audience).sum(:spend)

    if impressions > 0
      return spend/(impressions/1000)
    else
      return nil
    end
  end
end
