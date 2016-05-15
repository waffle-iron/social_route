class ReportPdf < Prawn::Document
  require "open-uri"

  def initialize(account_name,
                 dates,
                 campaign_overview,
                 campaign_objectives_overview,
                 cpm_by_placement,
                 cpm_by_audience_and_objective,
                 results_by_age_and_gender,
                 results_by_audience,
                 cpm_by_audience)

    super(page_layout: :landscape, page_size: 'A4', stroke_color: "#56A8D8")
    @account_name = account_name
    @dates = dates

    @kpis = campaign_overview
    @campaign_objectives_overview = campaign_objectives_overview
    @cpm_by_placement = cpm_by_placement
    @cpm_by_audience_and_objective = cpm_by_audience_and_objective

    @results_by_audience = results_by_audience
    @cpm_by_audience = cpm_by_audience

    @results_by_age_and_gender = results_by_age_and_gender

    cover_page
    outline_page
    campaign_overview_page
    campaign_overview_objectives_page
    audience_breakdown_page
    cpm_by_placement_page
    cpm_by_audience_and_objective_page
    total_results_by_age_and_gender_page
    results_by_audience_page
    cpm_by_audience_page
  end

  def cover_page
    move_down(115)
    text @account_name, size: 70, :color => "1F1F1F",:align => :center
    move_down(200)
    text @dates, size: 20, :color => "767676",:align => :center
    social_route_logo = open('http://www.thesocialroute.com/wp-content/uploads/2016/02/SocialRoute_WebLogo2.png')
    image social_route_logo, :at => [250,50], :scale => 0.75
  end

  def outline_page
    start_new_page(:size => "A4", :layout => :landscape)
    header
    move_down(40)
    text 'Outline', size: 35, :color => "767676",:align => :center, :style => :bold
    move_down(10)
    draw_text '1', size: 10, :at => [40,15]
    bullet_item(1, "Campaign Overview")
    bullet_item(1, "Audience Breakdown")
    bullet_item(1, "Campaign Performance")
    bullet_item(2, "Cost per 1,000 Impressions by Placement")
    bullet_item(2, "Cost per 1,000 Impressions by Audience & Objective")
    bullet_item(2, "Total Results by Age & Gender")
    bullet_item(2, "Results by Audience")
    bullet_item(2, "Cost per 1,000 Impressions by Audience")

    stroke do
      stroke_color '56A8D8'
      line_width 4
      stroke_rectangle [35, 425], 700, 350
    end

    stroke do
      stroke_color '767676'
      line_width 1
    end

    footer(1)
  end

  def campaign_overview_page
    start_new_page(:size => "A4", :layout => :landscape)
    header
    page_title('Campaign Overview')

    stroke do
      stroke_color '56A8D8'
      line_width 6
    end

    offset = 0

    @kpis.each do |kpi|
      stroke_circle([80 + offset, 275], 65)
      draw_text kpi[1], size: 20, :at => [(30 + offset), 275]
      draw_text kpi[0], size: 15, :at => [(30 + offset), 250]
      offset = offset + 200
    end

    stroke do
      stroke_color '767676'
      line_width 1
    end

    footer(2)
  end

  def campaign_overview_objectives_page
    start_new_page(:size => "A4", :layout => :landscape)
    header
    page_title('Campaign Overview')

    table(@campaign_objectives_overview, row_colors: ['BBDEFB', '90CAF9'],
                width: bounds.width,
                cell_style: {height: 65, size: 16, font_style: :bold, align: :center, border_color: 'FFFFFF'}) do
      row(0).style :background_color => '56A8D8'
      row(0).text_color = 'FFFFFF'
      row(0).size = 18
      row(0..4).valign = :center
    end

    footer(3)
  end

  def audience_breakdown_page
    start_new_page(:size => "A4", :layout => :landscape)
    header
    page_title('Audience Breakdown')

    data = [['<b>Audience #1</b>', '<b>Audience #2</b>', '<b>Audience #3</b>']]
    data.push(['People Aged 18-65+', 'People Aged 18-65+', 'People Aged 18-65+'])
    data.push(['<b>Geolocations<br><br></b>Colorado Springs - 10 mi', '<b>Geolocations<br><br></b>Colorado Springs - 10 mi', '<b>Geolocations<br><br></b>Colorado Springs - 10 mi'])
    data.push(['Audience Size: 160,000', 'Audience Size: 2,600,000', 'Audience Size: 850,000'])

    table(data, row_colors: ['BBDEFB', '90CAF9'],
                width: bounds.width,
                cell_style: {size: 14, align: :center, border_color: 'FFFFFF', border_width: 3,  :inline_format => true}) do
      column(0).style :background_color => '56A8D8'
      column(1).style :background_color => '90CAF9'
      column(2).style :background_color => 'BBDEFB'
      row(0).size = 16
      row(0..4).valign = :center
    end

    footer(4)
  end

  def cpm_by_placement_page
    start_new_page(:size => "A4", :layout => :landscape)
    header
    page_title('Cost per 1,000 Impressions by Placement')
    data = {views: @cpm_by_placement}
    chart data, legend: false, format: :currency, baseline: true, color: '56A8D8', label: true
    footer(5)
  end

  def cpm_by_audience_and_objective_page
    start_new_page(:size => "A4", :layout => :landscape)
    header
    page_title('Cost per 1,000 Impressions by Audience & Objective')

    chart @cpm_by_audience_and_objective, legend: true,
                                          formats: [:currency, :currency, :currency, :currency],
                                          baseline: true,
                                          colors: ['3D8FBF', '56A8D8', '90CAF9', 'BBDEFB'],
                                          labels: [true, true, true, true]
    footer(6)
  end

  def total_results_by_age_and_gender_page
    start_new_page(:size => "A4", :layout => :landscape)
    header
    page_title('Total Results by Age & Gender')
    data = {"Male #{@results_by_age_and_gender[0]}%".to_sym => @results_by_age_and_gender[2],
            "Female #{@results_by_age_and_gender[1]}%".to_sym => @results_by_age_and_gender[3]}
    chart data, legend: true, formats: [:percentage, :percentage], baseline: true, colors: ['56A8D8', 'EC407A'], labels: [true, true]
    footer(7)
  end

  def results_by_audience_page
    start_new_page(:size => "A4", :layout => :landscape)
    header
    page_title('Results by Audience')
    data = {views: @results_by_audience}
    chart data, legend: false, baseline: true, color: '56A8D8', label: true
    footer(8)
  end

  def cpm_by_audience_page
    start_new_page(:size => "A4", :layout => :landscape)
    header
    page_title('Cost per 1,000 Impressions by Audience')
    data = {views: @cpm_by_audience}
    chart data, legend: false, format: :currency, baseline: true, color: '56A8D8', label: true
    footer(9)
  end

  private

  def header
    formatted_text([
      {:text => @account_name,
       :styles => [:bold, :italic],
       :at => [40,500],
       :size => 20,
      :color => "767676"
     }])
  end

  def page_title(title)
    move_down(10)
    text title, size: 30, :color => "767676",:align => :center
    text @dates, size: 20, :color => "767676",:align => :center
    move_down(30)
  end

  def footer(page_number)
    social_route_logo = open('http://www.thesocialroute.com/wp-content/uploads/2016/02/SocialRoute_WebLogo2.png')
    image social_route_logo, :at => [625,25], :scale => 0.50
    draw_text page_number, size: 10, :at => [40,15]
  end

  def bullet_item(level = 1, string)
    indent (50 * level), 0 do
        text "• " + string, size: 20, color: "767676", leading: 7
    end
  end
end
