class ApiController < ApplicationController
  include ActionView::Helpers::NumberHelper
  include ApiHelper

  before_action :set_account_params
  before_action :require_login

  def dashboard
    render json: Account.where(account_id: allowed_accounts)
  end

  def accounts
    render json: Account.all
  end

  def overview
    render json: campaign_data
  end

  def overview_adets
    render json: adset_data
  end

  def naming_verification
    campaign_errors = Campaign.where(name_flagged: true)
    adset_errors    = Adset.where(name_flagged: true)
    ad_errors       = Ad.where(name_flagged: true)

    render json: {campaigns: campaign_errors,
                  adsets: adset_errors,
                  ads:ad_errors}
  end

  def reporting
    respond_to do |format|
      format.json do
        render json: {date_range: @date_range,
                      overview: overview_stats,
                      account_stats: account_stats,
                      cpm_cpr_placement: cpm_cpr_placement,
                      audiences: cpm_by_audience,
                      demographics: {age_and_gender: age_and_gender,
                                     audience_breakdowns: audience_demographics},
                      ad_formats: ad_formats,
                      ad_data: ad_data,
                      best_ad_creative: best_ad_creative,
                      targeting: targeting,
                      best_ads: best_ads
                    }
      end

      format.pdf { build_pdf }
    end
  end

  def account_stats
    {
      impressions: Ad2.where(account_id: @account_id_number).select(:impressions).sum(:impressions),
      website_clicks: Ad2Action.where(account_id: @account_id_number, action_type: 'link_click').sum(:value),
      website_conversions: Ad2Action.where(account_id: @account_id_number, action_type: 'offsite_conversion').sum(:value),
      video_views: Ad2Action.where(account_id: @account_id_number, action_type: 'video_view').sum(:value),
      post_engagement: Ad2Action.where(account_id: @account_id_number, action_type: ['comment', 'post', 'post_like', 'like']).sum(:value)
    }
  end

  def overview_stats
    impressions = Ad2.where(account_id: @account_id_number).group(:objective).sum(:impressions).map{|k,v| {objective: k, impressions: v}}
    reach =       Ad2.where(account_id: @account_id_number).group(:objective).sum(:reach).map{|k,v| {objective: k, reach: v}}
    spend =       Ad2.where(account_id: @account_id_number).group(:objective).sum(:spend).map{|k,v| {objective: k, spend: v}}

    results = [
      {objective: "LINK_CLICKS",     results: Ad2Action.where(account_id: @account_id_number, objective: 'LINK_CLICKS', action_type: 'link_click').sum(:value)},
      {objective: 'POST_ENGAGEMENT', results: Ad2Action.where(account_id: @account_id_number, objective: 'POST_ENGAGEMENT', action_type: 'post_engagement').sum(:value)},
      {objective: 'VIDEO_VIEWS',     results: Ad2Action.where(account_id: @account_id_number, objective: 'VIDEO_VIEWS', action_type: 'video_view').sum(:value)},
      {objective: 'CONVERSIONS',     results: Ad2Action.where(account_id: @account_id_number, objective: 'CONVERSIONS', action_type: "offsite_conversion").sum(:value)}
    ]

    combined_data = impressions + reach + spend + results

    return combined_data.group_by{|h| h[:objective]}.map{|k,v| v.reduce(:merge)}
  end

  def cpm_cpr_placement
    data = Array.new

    result_columns = ['video_view', 'offsite_conversion', 'comment', 'post',
                      'post_like', 'like', 'link_click']

    placements = [{name: 'Desktop News Feed',    placement_columns: ['desktop_feed', 'desktop_video_channel']},
                  {name: 'Mobile News Feed',     placement_columns: ['mobile_feed', 'mobile_video_channel']},
                  {name: 'Desktop Right Column', placement_columns: 'right_hand'},
                  {name: 'Instagram',            placement_columns: 'instagramstream'},
                  {name: 'Audience Network',     placement_columns: 'mobile_external_only'}]

    placements.each do |placement|
      impressions = Ad2Placement.where(account_id: @account_id_number, placement: placement[:placement_columns]).sum(:impressions).to_f
      spend       = Ad2Placement.where(account_id: @account_id_number, placement: placement[:placement_columns]).sum(:spend)
      results     = Ad2PlacementAction.where(account_id: @account_id_number, placement: placement[:placement_columns], action_type: result_columns).sum(:value)

      data.push(placement: placement[:name], cpm: spend/(impressions/1000), cpr: spend/results)
    end

    return data
  end

  def cpm_by_audience
    cpm_by_audience_and_objective = Array.new
    audiences = AdsetTargeting.where(account_id: @account_id).order(:audience).pluck('audience').uniq
    objectives = Campaign.where(account_id: @account_id_number).pluck('objective').uniq

    objectives.each do |objective|
      objective_data = Hash.new

      objective_data.merge!(objective: objective_name(objective))

      audiences.each do |audience|
        if check_audience_for_objective(audience, objective) > 0
          objective_data.merge!(audience.to_s.to_sym =>
                                calculate_cpm(objective, audience))
        else
          objective_data.merge!(audience.to_s.to_sym =>
                      nil)
        end
      end

      cpm_by_audience_and_objective.push(objective_data)
    end

    return {data: cpm_by_audience_and_objective, audiences: audiences}
  end

  def check_audience_for_objective(audience, objective)
    Campaign.where(account_id: @account_id_number, objective: objective, audience: audience).uniq.count
  end

  def age_and_gender
    age_and_gender_breakdowns = Array.new
    ages = ['13-17', '18-24', '25-34', '45-54', '55-64', '65+']
    age_and_gender_columns = ['video_view', 'offsite_conversion', 'comment',
                              'post', 'post_like', 'like', 'link_click']

    ages.each do |age|
      results = Ad2AgeAndGenderAction.where(account_id: @account_id_number, action_type: age_and_gender_columns, age: ages, gender: ['male', 'female', 'unknown']).sum(:value)
      male_age_results = Ad2AgeAndGenderAction.where(account_id: @account_id_number, action_type: age_and_gender_columns, age: age, gender: ['male', 'unknown']).sum(:value)
      female_age_results = Ad2AgeAndGenderAction.where(account_id: @account_id_number, action_type: age_and_gender_columns, age: age, gender: 'female').sum(:value)

      age_and_gender_breakdowns.push(age: age, male_results: (male_age_results/results)*100, female_results: (female_age_results/results)*100)
    end

    return age_and_gender_breakdowns
  end

  def audience_demographics
    audience_demographics = Array.new
    audiences = Ad2.where(account_id: @account_id_number).order(:audience).pluck('audience').uniq
    columns = ['video_view', 'offsite_conversion', 'comment', 'post', 'post_like', 'like', 'link_click']
    total_results = Ad2Action.where(account_id: @account_id_number, action_type: columns).sum(:value)
    cleaned_audiences = Array.new

    audiences.each do |audience|
      results = Ad2Action.where(account_id: @account_id_number, action_type: columns, audience: audience).sum(:value)
      percentage = (results/total_results)*100

      if percentage >= 1
        cleaned_audiences.push(audience)
      end
    end

    cleaned_audiences.each do |audience|
      spend = Ad2.where(account_id: @account_id_number, audience: audience).sum(:spend)
      results = Ad2Action.where(account_id: @account_id_number, action_type: columns, audience: audience).sum(:value)
      impressions = Ad2.where(account_id: @account_id_number, audience: audience).sum(:impressions).to_f

      audience_demographics.push(audience: number_with_delimiter(audience, delimiter: ','),
                                 results: results,
                                 cpr: spend/results,
                                 cpm: spend/(impressions/1000))
    end

    return audience_demographics
  end

  def campaign_data
    raw_data = Array.new
    objectives = Campaign.where(account_id: @account_id_number).pluck('objective').uniq

    objectives.each do |objective|
      campaign_data = Array.new
      campaigns = Campaign.where(account_id: @account_id_number, objective: objective)

      campaigns.each do |campaign|
        results = CampaignAction.where(campaign_id: campaign.campaign_id, action_type: result_columns(campaign.objective)).sum(:value)
        rr = (results/campaign.impressions.to_f)*100
        cpm = campaign.spend/(campaign.impressions.to_f/1000)
        score = cpm * (1/rr)

        campaign_data.push(campaign_id:   campaign.campaign_id,
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

    adsets = Adset.where(account_id: @account_id_number)

    adsets.each do |adset|
      adset_insight = AdsetInsight.where(adset_id: adset.adset_id)

      raw_data.push(adset:  {name: adset.name,
                             adset_id: adset.adset_id,
                             account_id: adset.account_id,
                             campaign_id: adset.campaign_id,
                             status: adset.status,
                             daily_budget: adset.daily_budget/100,
                             audience: adset.audience,
                             impressions: adset_insight.sum(:impressions),
                             spend: adset_insight.sum(:spend),
                             frequency: adset_insight.average(:frequency),
                             cpm: adset_insight.sum(:spend)/(adset_insight.sum(:impressions).to_f/1000)
                             })

    end

    return raw_data
  end

  def ad_formats
    final_data = Array.new
    columns = ['video_view', 'offsite_conversion', 'comment', 'post', 'post_like', 'like', 'link_click']

    impressions = Ad2.where(account_id: @account_id_number).group(:format).sum(:impressions).map{|k,v| {format: k, impressions: v}}
    spend = Ad2.where(account_id: @account_id_number).group(:format).sum(:spend).map{|k,v| {format: k, spend: v}}
    results = Ad2Action.where(account_id: @account_id_number, action_type: columns).group(:format).sum(:value).map{|k,v| {format: k, results: v}}

    raw_data = impressions + spend + results
    json_data = raw_data.group_by{|h| h[:format]}.map{|k,v| v.reduce(:merge)}

    json_data.each do |data|
      unless data[:format].to_s == 'VIDEO' || data[:format].to_s == 'Mislabeled'
        final_data.push(format: data[:format],
                        cpm: data[:spend]/(data[:impressions].to_f/1000),
                        cpr:data[:spend]/ data[:results],
                        creative: Ad2.where(account_id: @account_id_number, format: data[:format]))
      end
    end

    return final_data
  end

  def ad_data
    final_data = Array.new

    columns = ['video_view', 'offsite_conversion', 'comment', 'post', 'post_like', 'like', 'link_click']
    impressions = Ad2.where(account_id: @account_id_number).group(:simple_name).sum(:impressions).map{|k,v| {simple_name: k, impressions: v}}
    spend = Ad2.where(account_id: @account_id_number).group(:simple_name).sum(:spend).map{|k,v| {simple_name: k, spend: v}}
    results = Ad2Action.where(account_id: @account_id_number, action_type: columns).group(:simple_name).sum(:value).map{|k,v| {simple_name: k, results: v}}
    raw_data = impressions + spend + results
    json_data = raw_data.group_by{|h| h[:simple_name]}.map{|k,v| v.reduce(:merge)}

    json_data.each do |data|
      unless data[:simple_name].to_s == '2016' || data[:simple_name].to_s == 'Mislabeled'
        ads_by_simple_name = Ad2.where(account_id: @account_id_number, simple_name: data[:simple_name])

        best_ad_creatives = Array.new

        ads_by_simple_name.each do |ad|
          cpm = ad.spend/(ad.impressions.to_f/1000)
          results = Ad2Action.where(account_id: @account_id_number, simple_name: data[:simple_name], action_type: columns).sum(:value).to_f
          cpr = ad.spend/results

          best_ad_creatives.push({
            ad_id: ad.ad_id,
            cpm: cpm,
            cpr: cpr
          })
        end

        best_cpm_creative_ad_id = best_ad_creatives.sort_by { |hsh| hsh[:cpm] }.first[:ad_id]
        best_cpr_creative_ad_id = best_ad_creatives.sort_by { |hsh| hsh[:cpr] }.first[:ad_id]

        best_cpm_ad_creative = AdCreativeLookup.find_by_ad_id(best_cpm_creative_ad_id)
        best_cpm_creative = AdAccountCreative.find_by_creative_id(best_cpm_ad_creative.creative_id)

        best_cpr_ad_creative = AdCreativeLookup.find_by_ad_id(best_cpr_creative_ad_id)
        best_cpr_creative = AdAccountCreative.find_by_creative_id(best_cpr_ad_creative.creative_id)

        final_data.push(simple_name: data[:simple_name],
                        cpm: data[:spend]/(data[:impressions].to_f/1000),
                        cpr: data[:spend]/ data[:results],
                        best_cpm_creative: best_cpm_creative,
                        best_cpr_creative: best_cpr_creative)
      end
    end

    return final_data
  end

  def best_ad_creative
    score_array = Array.new

    columns = ['video_view', 'offsite_conversion', 'comment', 'post', 'post_like', 'like', 'link_click']
    impressions = Ad2.where(account_id: @account_id_number).group(:simple_name).sum(:impressions).map{|k,v| {simple_name: k, impressions: v}}
    spend = Ad2.where(account_id: @account_id_number).group(:simple_name).sum(:spend).map{|k,v| {simple_name: k, spend: v}}
    results = Ad2Action.where(account_id: @account_id_number, action_type: columns).group(:simple_name).sum(:value).map{|k,v| {simple_name: k, results: v}}
    raw_data = impressions + spend + results
    json_data = raw_data.group_by{|h| h[:simple_name]}.map{|k,v| v.reduce(:merge)}

    json_data.each do |data|
      cpm = data[:spend].to_f/(data[:impressions].to_f/1000)
      results = Ad2Action.where(account_id: @account_id_number, simple_name: data[:simple_name], action_type: columns).sum(:value).to_f
      cpr = data[:spend]/results

      score_array.push({
        simple_name: data[:simple_name],
        score: cpm * cpr
      })
    end

    best_simple_name = score_array.sort_by { |hsh| hsh[:score] }.first[:simple_name]

    results = Ad2Action.where(account_id: @account_id_number, simple_name: best_simple_name, action_type: columns).sum(:value).to_f
    spend = Ad2.where(account_id: @account_id_number, simple_name: best_simple_name).sum(:spend)
    reach = Ad2.where(account_id: @account_id_number, simple_name: best_simple_name).sum(:reach)
    impressions = Ad2.where(account_id: @account_id_number, simple_name: best_simple_name).sum(:impressions).to_f

    ad_id = Ad2.where(account_id: @account_id_number, simple_name: best_simple_name).first.ad_id
    creative_id = AdCreativeLookup.find_by_ad_id(ad_id).creative_id
    creative = AdAccountCreative.find_by_creative_id(creative_id)

    return {
      simple_name: best_simple_name,
      results: results,
      cpr: spend/results,
      reach: reach,
      impressions: impressions,
      cpm: spend/(impressions/1000),
      creative: creative
    }

  end

  def targeting
    target_data = Array.new
    audiences = AdsetTargeting.where(account_id: @account_id_number).order(:audience).pluck('audience').uniq

    audiences.each do |audience|
      ad_target = AdsetTargeting.where(audience: audience, account_id:  @account_id_number).last
      audience_formatted = audience

      if ad_target

        if ad_target.age_min != nil && ad_target.age_max != nil
          age_min = ad_target.age_min
          age_max = ad_target.age_max
        else
          age_min = nil
          age_max = nil
        end

        target_data.push(name: "Audience: #{audience_formatted}",
                         min_age: age_min,
                         max_age: age_max,
                         cities: ad_target.cities,
                         interests: ad_target.interests)
      end
    end

    return target_data
  end

  def best_ads
    best_ads = Array.new
    objectives = Ad.where(account_id: @account_id_number).pluck('objective').uniq

    objectives.each do |objective|
      best_ads.push(objective: objective_name(objective), ads: calculate_best_ads(objective))
    end

    return best_ads
  end

  def build_pdf
    pdf = ReportPdf.new(@account.name,
                        @date_range,
                        campaign_overview_pdf,
                        campaign_objectives_overview_pdf,
                        audience_pdf,
                        cpm_by_placement_pdf,
                        cpm_by_audience_and_objective_pdf,
                        results_by_age_and_gender_pdf,
                        results_by_audience_pdf,
                        cpm_by_audience_pdf,
                        cpm_by_ad_format_pdf,
                        ad_creative_count_pdf,
                        cpm_by_ad_creative_pdf,
                        cpm_by_ad_creative_first_pdf,
                        cpm_by_ad_creative_last_pdf,
                        best_ad_creative_pdf)

    send_data pdf.render, filename: "#{@account.name}.pdf",
                          type: "application/pdf",
                          disposition: "inline"
  end

  def campaign_overview_pdf
    campaign_overview = Array.new

    impressions = Ad2.where(account_id: @account_id_number).select(:impressions).sum(:impressions),
    website_clicks = Action.where(account_id: @account_id, action_type: 'link_click', gender: nil, age: nil).sum(:value)
    website_conversions = Action.where(account_id: @account_id, action_type: 'offsite_conversion', gender: nil, age: nil).sum(:value)
    post_engagement = Action.where(account_id: @account_id, action_type: ['comment', 'post', 'post_like', 'like'], gender: nil, age: nil).sum(:value)
    video_views = Action.where(account_id: @account_id, action_type: 'video_view', gender: nil, age: nil).sum(:value)

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

    # ToDo
    if video_views > 50
      campaign_overview.push(['Video Views'.upcase, number_with_delimiter(video_views.round(0), delimiter: ',') ])
    end

    return campaign_overview
  end

  def campaign_objectives_overview_pdf
    campaign_objectives_overview = [['Campaign Objective', 'Results', 'CPR', 'Reach', 'Impressions', 'CPM']]

    overview_stats.each do |objective_data|
      if objective_data[:results] && objective_data[:results] > 0 && objective_data[:impressions].to_f > 0
        cpr = number_to_currency(objective_data[:spend]/objective_data[:results].to_f)
        cpm = number_to_currency(objective_data[:spend]/(objective_data[:impressions].to_f/1000))

        campaign_objectives_overview.push([objective_name(objective_data[:objective]),
                                          number_with_delimiter(objective_data[:results].round(0), delimiter: ','),
                                          cpr,
                                          number_with_delimiter(objective_data[:reach].round(0), delimiter: ','),
                                          number_with_delimiter(objective_data[:impressions].to_f.round(0), delimiter: ','),
                                          cpm])
      end
    end

    return campaign_objectives_overview
  end

  def audience_pdf
    audiences = AdsetTargeting.where(account_id: @account_id).order(:audience).pluck('audience').uniq
    audience_data = Array.new
    audience_names = Array.new
    audience_ages = Array.new
    audience_interests = Array.new
    audience_cities = Array.new

    audiences.each do |audience|
      unless audience == 'POST' or audience == 'MULTIAUDIENCE'
        data = AdsetTargeting.where(account_id: @account_id, audience: audience).last

        if is_number?(audience)
          audience_formatted = number_with_delimiter(audience, delimiter: ',')
        else
          audience_formatted = audience
        end

        audience_names.push("<b>#{audience_formatted} Audience</b>")

        if data
          age_min = data.age_min
          age_max = data.age_max

          if age_max >= '65'
            extra = '+'
          else
            extra = ''
          end

          audience_ages.push("People Aged #{age_min}-#{age_max}#{extra}")

          if data.interests.length > 0
            audience_interests.push('<b>Interests</b><br><br>'.concat(data.interests.join("<br>")))
          else
            audience_interests.push('')
          end

          if data.cities.length > 0
            audience_cities.push('<b>Geolocations</b><br><br>'.concat(data.cities.join("<br>")))
          else
            audience_cities.push('')
          end
        end
      end
    end

    audience_data.push(audience_names, audience_ages)

    # if audience_interests.length > 0
    #   audience_data.push(audience_interests)
    # end

    if audience_cities.length > 0
      audience_data.push(audience_cities)
    end

    return audience_data
  end

  def cpm_by_placement_pdf
    return cpm_by_placement.map { |data| [data[:placement], data[:cpm]]}.to_h
  end

  def cpm_by_audience_and_objective_pdf
    cpm_by_audience_and_objective = Hash.new
    audiences = AdsetTargeting.where(account_id: @account_id).order(:audience).pluck('audience').uniq

    objectives = Campaign.where(account_id: @account_id_number).pluck('objective').uniq

    audiences.each do |audience|
      audience_formatted = number_with_delimiter(audience, delimiter: ',').to_s
      audience_objective_data = Hash.new

      objectives.each do |objective|
        audience_objective_data.merge!(objective_name(objective).to_sym => calculate_cpm(objective, audience))
      end

      cpm_by_audience_and_objective.merge!({"#{audience_formatted} Audience".to_s.to_sym => audience_objective_data})
    end

    return cpm_by_audience_and_objective
  end

  def results_by_age_and_gender_pdf
    results_by_age_and_gender = Array.new

    age_and_gender_columns = ['video_view', 'offsite_conversion', 'comment',
                              'post', 'post_like', 'like', 'link_click']
    ages = ['13-17', '18-24', '25-34', '45-54', '55-64', '65+']

    results = Action.where(account_id: @account_id, action_type: age_and_gender_columns, age: ages, gender: ['male', 'female', 'unknown']).sum(:value)
    male_age_results = Action.where(account_id: @account_id, action_type: age_and_gender_columns, age: ages, gender: ['male', 'unknown']).sum(:value)
    female_age_results = Action.where(account_id: @account_id, action_type: age_and_gender_columns, age: ages, gender: 'female').sum(:value)

    male_results = Action.where(account_id: @account_id, action_type: age_and_gender_columns, gender: ['male', 'unkown']).sum(:value)
    female_results = Action.where(account_id: @account_id, action_type: age_and_gender_columns, gender: 'female').sum(:value)
    total_results = Action.where(account_id: @account_id, action_type: age_and_gender_columns).sum(:value)

    results_by_age_and_gender.push(((male_age_results/results)*100).round(1))
    results_by_age_and_gender.push(((female_age_results/results)*100).round(1))
    results_by_age_and_gender.push(age_and_gender.map { |data| [data[:age], (data[:male_results]).round(1)]}.to_h)
    results_by_age_and_gender.push(age_and_gender.map { |data| [data[:age], (data[:female_results]).round(1)]}.to_h)

    return results_by_age_and_gender
  end

  def results_by_audience_pdf
    return audience_demographics.map { |data| [data[:audience], data[:results]]}.to_h
  end

  def cpm_by_audience_pdf
    return audience_demographics.map { |data| [data[:audience], data[:cpm]]}.to_h
  end

  def cpm_by_ad_format_pdf
    return ad_formats.map { |data| [data[:format], data[:cpm]]}.to_h
  end

  def ad_creative_count_pdf
    return ad_data.count
  end

  def cpm_by_ad_creative_pdf
    return ad_data.map { |data| [data[:simple_name], data[:cpm]]}.to_h
  end

  def cpm_by_ad_creative_first_pdf
    return ad_data[0..12].map { |data| [data[:simple_name], data[:cpm]]}.to_h
  end

  def cpm_by_ad_creative_last_pdf
    if ad_data.length >= 13
      return ad_data[13..-1].map { |data| [data[:simple_name], data[:cpm]]}.to_h
    else
      return nil
    end
  end

  def best_ad_creative_pdf
  end

  private

  def set_account_params
    @account = Account.find_by_account_id(params['account_id'])
    @account_id = params['account_id']
    @account_id_number = params['account_id'].to_s[4..-1]
    @date_range = account_dates(@account_id_number)
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
    impressions = Campaign.where(account_id: @account_id_number, objective: objective, audience: audience).sum(:impressions).to_f
    spend = Campaign.where(account_id: @account_id_number, objective: objective, audience: audience).sum(:spend)

    if impressions > 0
      return spend/(impressions/1000)
    else
      return nil
    end
  end

  def calculate_best_ads(objective)
    best_ads = Array.new
    ads = Ad.where(account_id: @account_id_number, objective: objective)

    ads[-2..-1].each do |ad|
      ad_creative = AdCreativeLookup.find_by_ad_id(ad.ad_id)
      creative = AdAccountCreative.find_by_creative_id(ad_creative.creative_id)

      best_ads.push({
        results: 1,
        cpr: 1,
        reach: ad.reach,
        impressions: ad.impressions,
        cpm: ad.spend/(ad.impressions.to_f/1000),
        creative: creative
      })
    end

    return best_ads
  end

  def is_number? string
    true if Float(string) rescue false
  end
end

class Array
  def pluck(key)
    map { |h| h[key] }
  end
end
