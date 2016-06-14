@thesocialroute.controller 'ReportingCtrl', [
  '$scope'
  'Reporting'
  '$filter'
  '$window'
  '$http'

  @DashboardCtrl = ($scope, Reporting, $filter, $window, $http) ->
    numberFilter = $filter('number')
    currencyFilter = $filter('currency')

    $scope.generateReport = (account_id)=>
        $window.open('/api/reporting.pdf?account_id=' + getParameterByName('account_id')
                     ,'_blank')

    getParameterByName = (name) ->
      url = window.location.href
      name = name.replace(/[\[\]]/g, '\\$&')
      regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)')
      results = regex.exec(url)
      if !results
        return null
      if !results[2]
        return ''
      decodeURIComponent results[2].replace(/\+/g, ' ')

    Reporting.index(account_id: getParameterByName('account_id')).$promise
    .then (reportingData) ->
      _.forEach reportingData.overview, (objectiveData) ->
        if objectiveData.objective is "CONVERSIONS"
          objectiveData.objectiveName = "Website Conversions"
        else if objectiveData.objective is "LINK_CLICKS"
          objectiveData.objectiveName = "Clicks to Website"
        else if objectiveData.objective is "POST_ENGAGEMENT"
          objectiveData.objectiveName = "Post Engagement"
        else if objectiveData.objective is "VIDEO_VIEWS"
          objectiveData.objectiveName = "Video Views"
        else
          objectiveData.objectiveName = objectiveData.objective

      $scope.reporting = reportingData

      createCpmByPlacementChart(reportingData.cpm_cpr_placement)
      createCprByPlacementChart(reportingData.cpm_cpr_placement)
      createAudiencesChart(reportingData.audiences)
      createAgeGenderChart(reportingData.demographics.age_and_gender)
      createGeneralChart(reportingData.demographics.audience_breakdowns)
      createGeneralChartCPM(reportingData.demographics.audience_breakdowns)
      createGeneralChartCPR(reportingData.demographics.audience_breakdowns)
      createAdFormatChart(reportingData.ad_formats)
      createAdFormatCPRChart(reportingData.ad_formats)
      createAdChart(reportingData.ad_data)
      createAdCPRChart(reportingData.ad_data)

    createCpmByPlacementChart = (cpmData) ->
      cpmChart = {}
      cpmChart.type = 'ColumnChart'
      cpmChart.data = [
        [
         {type: 'string', label: 'Placement'}
         {type: 'string', role: 'tooltip', p: {role: 'tooltip', html: true}}
         {type: 'number', label: 'CPM'}
         {type: 'string', role: 'annotation'}
        ]
      ]

      _.forEach cpmData, (n) ->
        cpmChart.data.push([
          n.placement
          {v: "<div style='width: 220px; padding: 20px;'>" +
              "<strong style='color: #424242'><p style='font-size: 200%'>" + n.placement + "</p></strong></span><br>" +
              "<p style='font-size: 120%'><span style='color: #616161'><b>CPM<br><span style='font-size: 200%; color:#0888C4;'>" + currencyFilter(n.cpm) + "<br></span></p>" +
              "</div>", p: {}
          }
          n.cpm
          currencyFilter(n.cpm)
        ])

      cpmChart.options =
        titleTextStyle: {color: '#797575' }
        displayExactValues: true
        is3D: true
        tooltip: {isHtml: true}
        focusTarget: 'category'
        displayAnnotations: true
        animation: { startup: true, duration: 1000, easing: 'in' }
        legend: { position: 'none'}
        hAxis: { title: '', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575' } }
        vAxis: { title: 'CPM', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'}, format: 'currency' }
        chartArea: {width: '80%', height: '80%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }
        colors: ['#0888C4']

      $scope.cpmChart = cpmChart

    createCprByPlacementChart = (cprData) ->
      cprByPlacementChart = {}
      cprByPlacementChart.type = 'ColumnChart'
      cprByPlacementChart.data = [
        [
         {type: 'string', label: 'Placement'}
         {type: 'string', role: 'tooltip', p: {role: 'tooltip', html: true}}
         {type: 'number', label: 'CPR'}
         {type: 'string', role: 'annotation'}
        ]
      ]

      _.forEach cprData, (n) ->
        cprByPlacementChart.data.push([
          n.placement
          {v: "<div style='width: 220px; padding: 20px;'>" +
              "<strong style='color: #424242'><p style='font-size: 200%'>" + n.placement + "</p></strong></span><br>" +
              "<p style='font-size: 120%'><span style='color: #616161'><b>CPM<br><span style='font-size: 200%; color:#0888C4;'>" + currencyFilter(n.cpr) + "<br></span></p>" +
              "</div>", p: {}
          }
          n.cpr
          currencyFilter(n.cpr)
        ])

      cprByPlacementChart.options =
        titleTextStyle: {color: '#797575' }
        displayExactValues: true
        is3D: true
        tooltip: {isHtml: true}
        focusTarget: 'category'
        displayAnnotations: true
        animation: { startup: true, duration: 1000, easing: 'in' }
        legend: { position: 'none'}
        hAxis: { title: '', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575' } }
        vAxis: { title: 'CPR', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'}, format: 'currency' }
        chartArea: {width: '80%', height: '80%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }
        colors: ['#0888C4']

      $scope.cprByPlacementChart = cprByPlacementChart

    createAudiencesChart = (rawData) ->
      audiencesChart = {}
      audiencesChart.type = 'BarChart'

      audiences = rawData.audiences
      colors = ['#022231', '#044462', '#0888c4', '#29b6f6']

      legendData = [{type: 'string', label: 'Audience'}, {type: 'string', role: 'tooltip', p: {role: 'tooltip', html: true}}]

      _.forEach audiences, (audience) ->
        legendData.push({type: 'number', label: audience + ' Audience'})

      audiencesChart.data = [legendData]

      _.forEach _.sortBy(rawData.data, 'objective'), (objectiveData) ->
          data = [objectiveData.objective]
          tooltipData = ''

          i = 1
          while i <= audiences.length
            if objectiveData[Object.keys(objectiveData)[i]] isnt null
              text = "<p style='font-size: 120%'><span style='color: #616161'><b> " +
                     Object.keys(objectiveData)[i] + " Audience <br><span style='font-size: 200%; color:" +
                     colors[i-1] + ";'>" +
                     currencyFilter(objectiveData[Object.keys(objectiveData)[i]]) +
                     "<br></span></p>"
              tooltipData = tooltipData + text
            i++

          tooltipData =
          data.push(
            {v: "<div style='width: 180px; padding: 20px;'>" +
                "<strong style='color: #424242'>" + objectiveData.objective + "</strong></span><br><br>" +
                tooltipData +
                "</div>", p: {}
            }
          )

          i = 1
          while i <= audiences.length
            data.push(objectiveData[Object.keys(objectiveData)[i]])
            i++

          audiencesChart.data.push(data)

      audiencesChart.options =
        titleTextStyle: {color: '#797575' }
        displayExactValues: true
        is3D: true
        tooltip: {isHtml: true}
        animation: { startup: true, duration: 1000, easing: 'in' }
        focusTarget: 'category'
        legend: { position: 'bottom'}
        hAxis: { title: 'CPM', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575' }, format: 'currency', viewWindowMode:'explicit', viewWindow: {min:0}  }
        vAxis: { title: '', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'} }
        chartArea: {width: '70%', height: '70%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }
        colors: colors

      $scope.audiencesChart = audiencesChart

    createAgeGenderChart = (ageGenderData) ->
      sum_male = numberFilter(_.sumBy(ageGenderData, 'male_results'), 1)
      sum_female = numberFilter(_.sumBy(ageGenderData, 'female_results'), 1)

      ageGenderChart = {}
      ageGenderChart.type = 'ColumnChart'
      ageGenderChart.data = [
        [
         {type: 'string', label: 'Gender'}
         {type: 'string', role: 'tooltip', p: {role: 'tooltip', html: true}}
         {type: 'number', label: 'Male ' + sum_male + '%'}
         {type: 'string', role: 'annotation'}
         {type: 'number', label: 'Female ' + sum_female  + '%'}
         {type: 'string', role: 'annotation'}
        ]
      ]

      _.forEach ageGenderData, (n) ->
        ageGenderChart.data.push([
          n.age
          {v: "<div style='width: 220px; padding: 20px;'>" +
              "<strong style='color: #424242'><p style='font-size: 200%'>Age: " + n.age + "</p></strong></span><br>" +
              "<p style='font-size: 120%'><span style='color: #616161'><b>Results Male<br><span style='font-size: 200%; color:#044462;'>" + numberFilter(n.male_results, 1) + '%' + "<br></span></p>" +
              "<p style='font-size: 120%'><span style='color: #616161'><b>Results Female<br><span style='font-size: 200%; color:#0888C4;'>" + numberFilter(n.female_results, 1) + '%' + "<br></span></p>" +
              "</div>", p: {}
          }
          numberFilter(n.male_results, 1)
          numberFilter(n.male_results, 1) + '%'
          numberFilter(n.female_results, 1)
          numberFilter(n.female_results, 1) + '%'
        ])

      ageGenderChart.options =
        titleTextStyle: {color: '#797575' }
        displayExactValues: true
        is3D: true
        tooltip: {isHtml: true}
        focusTarget: 'category'
        displayAnnotations: true
        bar: {groupWidth: "95%"},
        animation: { startup: true, duration: 1000, easing: 'in' }
        legend: { position: 'top', textStyle: {color: '#797575' }}
        hAxis: { title: '', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575' } }
        vAxis:{
         baselineColor: '#fff',
         gridlineColor: '#fff',
         textPosition: 'none'
       }
        chartArea: {width: '95%', height: '90%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }
        colors: ['#044462', '#0888C4']

      $scope.ageGenderChart = ageGenderChart

    createGeneralChart = (generalData)->
      generalChart = {}
      generalChart.type = 'ColumnChart'
      generalChart.data = [
        [
         {type: 'string', label: 'Audience'}
         {type: 'number', label: 'Results'}
         {type: 'string', role: 'annotation'}
         {type: 'string', role: 'tooltip', p: {role: 'tooltip', html: true}}
        ]
      ]

      _.forEach generalData, (data) ->
        percentage_raw = Math.round((data.results/(_.sumBy(generalData, 'results'))*100)*10)/10

        percentage = percentage_raw + '%'

        generalChart.data.push([
          data.audience
          data.results
          percentage
          {v: "<div style='width: 160px; padding: 20px;'>" +
              "<strong style='color: #424242'>" + data.audience + "</strong></span><br><br>" +
              "<p style='font-size: 120%'><span style='color: #616161'><b>Results <br><span style='font-size: 200%; color:#0888C4;'>" + numberFilter(data['results']) + "<br></span></p>" +
              "</div>", p: {}
          }
        ])

      generalChart.options =
        title: 'Results by Audience'
        titleTextStyle: {color: '#797575' }
        displayExactValues: true
        is3D: true
        displayAnnotations: true
        tooltip: {isHtml: true}
        animation: { startup: true, duration: 1000, easing: 'in' }
        focusTarget: 'datum'
        legend: { position: 'none'}
        hAxis: { title: '', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575' }}
        vAxis: {title: 'Results', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'}, viewWindowMode:'explicit', viewWindow: {min:0}}
        chartArea: {width: '80%', height: '80%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }
        colors: ['#0888C4']

      $scope.generalChart = generalChart

    createGeneralChartCPM = (generalData)->
      generalChartCPM = {}
      generalChartCPM.type = 'ColumnChart'
      generalChartCPM.data = [
        [
         {type: 'string', label: 'Audience'}
         {type: 'number', label: 'CPM'}
         {type: 'string', role: 'annotation'}
         {type: 'string', role: 'tooltip', p: {role: 'tooltip', html: true}}
        ]
      ]

      _.forEach generalData, (data) ->
        percentage_raw = Math.round((data.results/(_.sumBy(generalData, 'results'))*100)*10)/10

        percentage = percentage_raw + '%'

        generalChartCPM.data.push([
          data.audience
          data.cpm
          currencyFilter(data.cpm) + ' CPM'
          {v: "<div style='width: 160px; padding: 20px;'>" +
              "<strong style='color: #424242'>" + data.audience + "</strong></span><br><br>" +
              "<p style='font-size: 120%'><span style='color: #616161'><b>Results <br><span style='font-size: 200%; color:#0888C4;'>" + currencyFilter(data['cpm']) + "<br></span></p>" +
              "</div>", p: {}
          }
        ])

      generalChartCPM.options =
        title: 'CPM by Audience'
        titleTextStyle: {color: '#797575' }
        displayExactValues: true
        is3D: true
        displayAnnotations: true
        tooltip: {isHtml: true}
        animation: { startup: true, duration: 1000, easing: 'in' }
        focusTarget: 'datum'
        legend: { position: 'none'}
        hAxis: { title: '', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575' }}
        vAxis: {title: 'CPM', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'}, format: 'currency', viewWindowMode:'explicit', viewWindow: {min:0}}
        chartArea: {width: '80%', height: '80%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }
        colors: ['#0888C4']

      $scope.generalChartCPM = generalChartCPM

    createGeneralChartCPR = (generalData)->
      generalChartCPR = {}
      generalChartCPR.type = 'ColumnChart'
      generalChartCPR.data = [
        [
         {type: 'string', label: 'Audience'}
         {type: 'number', label: 'CPR'}
         {type: 'string', role: 'annotation'}
         {type: 'string', role: 'tooltip', p: {role: 'tooltip', html: true}}
        ]
      ]

      _.forEach generalData, (data) ->

        percentage_raw = Math.round((data.results/(_.sumBy(generalData, 'results'))*100)*10)/10

        percentage = percentage_raw + '%'

        generalChartCPR.data.push([
          data.audience
          data.cpr
          currencyFilter(data.cpr) + ' CPR'
          {v: "<div style='width: 160px; padding: 20px;'>" +
              "<strong style='color: #424242'>" + data.audience + "</strong></span><br><br>" +
              "<p style='font-size: 120%'><span style='color: #616161'><b>Results <br><span style='font-size: 200%; color:#0888C4;'>" + currencyFilter(data['cpr']) + "<br></span></p>" +
              "</div>", p: {}
          }
        ])

      generalChartCPR.options =
        title: 'CPR by Audience'
        titleTextStyle: {color: '#797575' }
        displayExactValues: true
        is3D: true
        displayAnnotations: true
        tooltip: {isHtml: true}
        animation: { startup: true, duration: 1000, easing: 'in' }
        focusTarget: 'datum'
        legend: { position: 'none'}
        hAxis: { title: '', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575' }}
        vAxis: {title: 'CPR', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'}, format: 'currency', viewWindowMode:'explicit', viewWindow: {min:0}}
        chartArea: {width: '80%', height: '80%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }
        colors: ['#0888C4']

      $scope.generalChartCPR = generalChartCPR

    createAdFormatChart = (adFormatData)->
      adFormatChart = {}
      adFormatChart.type = 'ColumnChart'
      adFormatChart.data = [
        [
         {type: 'string', label: 'Ad Format'}
         {type: 'number', label: 'CPM'}
         {type: 'string', role: 'annotation'}
         {type: 'string', role: 'tooltip', p: {role: 'tooltip', html: true}}
        ]
      ]

      _.forEach adFormatData, (data) ->
        adFormatChart.data.push([
          data.format
          data.cpm
          currencyFilter(data.cpm) + ' CPM'
          {v: "<div style='width: 160px; padding: 20px;'>" +
              "<strong style='color: #424242'>" + data.format + "</strong></span><br><br>" +
              "<p style='font-size: 120%'><span style='color: #616161'><b>CPM <br><span style='font-size: 200%; color:#0888C4;'>" + currencyFilter(data['cpm']) + "<br></span></p>" +
              "</div>", p: {}
          }
        ])

      adFormatChart.options =
        title: 'CPM by Ad Format'
        titleTextStyle: {color: '#797575' }
        displayExactValues: true
        is3D: true
        displayAnnotations: true
        tooltip: {isHtml: true}
        animation: { startup: true, duration: 1000, easing: 'in' }
        focusTarget: 'datum'
        legend: { position: 'none'}
        hAxis: { title: '', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'}}
        vAxis: {title: 'CPM', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'}, format: 'currency', viewWindowMode:'explicit', viewWindow: {min:0}}
        chartArea: {width: '80%', height: '80%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }
        colors: ['#0888C4']

      $scope.adFormatChart = adFormatChart

    createAdFormatCPRChart = (adFormatData)->
      adFormatCPRChart = {}
      adFormatCPRChart.type = 'ColumnChart'
      adFormatCPRChart.data = [
        [
         {type: 'string', label: 'Ad Format'}
         {type: 'number', label: 'CPR'}
         {type: 'string', role: 'annotation'}
         {type: 'string', role: 'tooltip', p: {role: 'tooltip', html: true}}
        ]
      ]

      _.forEach adFormatData, (data) ->
        adFormatCPRChart.data.push([
          data.format
          data.cpr
          currencyFilter(data.cpr) + ' CPR'
          {v: "<div style='width: 160px; padding: 20px;'>" +
              "<strong style='color: #424242'>" + data.format + "</strong></span><br><br>" +
              "<p style='font-size: 120%'><span style='color: #616161'><b>CPM <br><span style='font-size: 200%; color:#0888C4;'>" + currencyFilter(data['cpr']) + "<br></span></p>" +
              "</div>", p: {}
          }
        ])

      adFormatCPRChart.options =
        title: 'CPR by Ad Format'
        titleTextStyle: {color: '#797575' }
        displayExactValues: true
        is3D: true
        displayAnnotations: true
        tooltip: {isHtml: true}
        animation: { startup: true, duration: 1000, easing: 'in' }
        focusTarget: 'datum'
        legend: { position: 'none'}
        hAxis: { title: '', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'}}
        vAxis: {title: 'CPR', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'}, format: 'currency', viewWindowMode:'explicit', viewWindow: {min:0}}
        chartArea: {width: '80%', height: '80%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }
        colors: ['#0888C4']

      $scope.adFormatCPRChart = adFormatCPRChart

    createAdChart = (adData)->
      adDataChart = {}
      adDataChart.type = 'ColumnChart'
      adDataChart.data = [
        [
         {type: 'string', label: 'Creative'}
         {type: 'number', label: 'CPM'}
         {type: 'string', role: 'annotation'}
         {type: 'string', role: 'tooltip', p: {role: 'tooltip', html: true}}
        ]
      ]

      _.forEach adData, (data) ->
        adDataChart.data.push([
          data.simple_name
          data.cpm
          currencyFilter(data.cpm) + ' CPM'
          {v: "<div style='width: 160px; padding: 20px;'>" +
              "<strong style='color: #424242'>" + data.simple_name + "</strong></span><br>" +
              "<img src='" + data.best_cpm_creative.thumbnail_url + "' height='120' width='120'/>" +
              "<p style='font-size: 120%'><span style='color: #616161'><b>CPM <br><span style='font-size: 200%; color:#0888C4;'>" + currencyFilter(data['cpm']) + "<br></span></p>" +
              "</div>", p: {}
          }
        ])

      adDataChart.options =
        title: 'CPM by Creative'
        titleTextStyle: {color: '#797575' }
        displayExactValues: true
        is3D: true
        displayAnnotations: true
        tooltip: {isHtml: true}
        animation: { startup: true, duration: 1000, easing: 'in' }
        focusTarget: 'datum'
        legend: { position: 'none'}
        hAxis: { title: '', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575' }}
        vAxis: {title: 'CPM', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'}, format: 'currency', viewWindowMode:'explicit', viewWindow: {min:0}}
        chartArea: {width: '80%', height: '80%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }
        colors: ['#0888C4']

      $scope.adDataChart = adDataChart

    createAdCPRChart = (adData)->
      adDataCPRChart = {}
      adDataCPRChart.type = 'ColumnChart'
      adDataCPRChart.data = [
        [
         {type: 'string', label: 'Creative'}
         {type: 'number', label: 'CPR'}
         {type: 'string', role: 'annotation'}
         {type: 'string', role: 'tooltip', p: {role: 'tooltip', html: true}}
        ]
      ]

      _.forEach adData, (data) ->
        adDataCPRChart.data.push([
          data.simple_name
          data.cpr
          currencyFilter(data.cpr) + ' CPR'
          {v: "<div style='width: 160px; padding: 20px;'>" +
              "<strong style='color: #424242'>" + data.simple_name + "</strong></span><br>" +
              "<img src='" + data.best_cpr_creative.thumbnail_url + "' height='120' width='120'/>" +
              "<p style='font-size: 120%'><span style='color: #616161'><b>CPM <br><span style='font-size: 200%; color:#0888C4;'>" + currencyFilter(data['cpr']) + "<br></span></p>" +
              "</div>", p: {}
          }
        ])

      adDataCPRChart.options =
        title: 'CPR by Creative'
        titleTextStyle: {color: '#797575' }
        displayExactValues: true
        is3D: true
        displayAnnotations: true
        tooltip: {isHtml: true}
        animation: { startup: true, duration: 1000, easing: 'in' }
        focusTarget: 'datum'
        legend: { position: 'none'}
        hAxis: { title: '', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575' }}
        vAxis: {title: 'CPR', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'}, format: 'currency', viewWindowMode:'explicit', viewWindow: {min:0}}
        chartArea: {width: '80%', height: '80%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }
        colors: ['#0888C4']

      $scope.adDataCPRChart = adDataCPRChart

]
