@thesocialroute.controller 'ReportingCtrl', [
  '$scope'
  'Reporting'
  '$filter'

  @DashboardCtrl = ($scope, Reporting, $filter) ->
    numberFilter = $filter('number')
    currencyFilter = $filter('currency')

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
      createCpmChart(reportingData.cpm_cpr_placement)
      createAudiencesChart(reportingData.audiences)
      createGenderChart(reportingData.demographics.gender_breakdowns)
      createAgeChart(reportingData.demographics.age_breakdowns)
      createGeneralChart(reportingData.demographics.audience_breakdowns)
      createGeneralChartCPM(reportingData.demographics.audience_breakdowns)

    createCpmChart = (cpmData) ->
      cpmChart = {}
      cpmChart.type = 'ColumnChart'
      cpmChart.data = [
        [
         {type: 'string', label: 'Placement'}
         {type: 'string', role: 'tooltip', p: {role: 'tooltip', html: true}}
         {type: 'number', label: 'CPM'}
        ]
      ]

      _.forEach cpmData, (n) ->
        cpmChart.data.push([
          n.placement
          {v: "<div style='width: 220px; padding: 20px;'>" +
              "<strong style='color: #424242'><p style='font-size: 200%'>" + n.placement + "</p></strong></span><br>" +
              "<p style='font-size: 120%'><span style='color: #616161'><b>CPM<br><span style='font-size: 200%; color:#29B6F6;'>" + currencyFilter(n.cpm) + "<br></span></p>" +
              "</div>", p: {}
          }
          n.cpm
        ])

      cpmChart.options =
        titleTextStyle: {color: '#797575' }
        displayExactValues: true
        is3D: true
        tooltip: {isHtml: true}
        focusTarget: 'category'
        animation: { startup: true, duration: 1000, easing: 'in' }
        legend: { position: 'none'}
        hAxis: { title: '', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575' } }
        vAxis: { title: 'CPM', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'}, format: 'currency' }
        chartArea: {width: '80%', height: '80%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }
        colors: ['#29B6F6']

      $scope.cpmChart = cpmChart

    createCprChart = (cprData)->
      cprChart = {}
      cprChart.type = 'ColumnChart'
      cprChart.data = [
        [
         {type: 'string', label: 'Placement'}
         {type: 'string', role: 'tooltip', p: {role: 'tooltip', html: true}}
         {type: 'number', label: 'CPR'}
        ]
      ]

      _.forEach cprData, (n) ->
        cprChart.data.push([
          n.placement
          {v: "<div style='width: 220px; padding: 20px;'>" +
              "<strong style='color: #424242'><p style='font-size: 200%'>" + n.placement + "</p></strong></span><br>" +
              "<p style='font-size: 120%'><span style='color: #616161'><b>CPR<br><span style='font-size: 200%; color:#29B6F6;'>" + currencyFilter(n.cpr) + "<br></span></p>" +
              "</div>", p: {}
          }
          n.cpr
        ])

      cprChart.options =
        titleTextStyle: {color: '#797575' }
        displayExactValues: true
        is3D: true
        tooltip: {isHtml: true}
        focusTarget: 'category'
        animation: { startup: true, duration: 1000, easing: 'in' }
        legend: { position: 'none'}
        hAxis: { title: '', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575' }}
        vAxis: { title: 'CPR', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'} }
        chartArea: {width: '80%', height: '80%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }
        colors: ['#E91E63']

      $scope.cprChart = cprChart

    createAudiencesChart = (objectives)->
      audiencesChart = {}
      audiencesChart.type = 'BarChart'

      audiencesChart.data = [
        [
         {type: 'string', label: 'Audience'}
         {type: 'string', role: 'tooltip', p: {role: 'tooltip', html: true}}
         {type: 'number', label: '10,000 Audience'}
         {type: 'number', label: '160,000 Audience'}
         {type: 'number', label: '2,200,000 Audience'}
         {type: 'number', label: '520,000 Audience'}
        ]
      ]

      _.forEach objectives, (objectiveData) ->
          if objectiveData.audiences.length is 1
            cpm_1 = objectiveData.audiences[0]['spend']/(objectiveData.audiences[0]['impressions']/1000)
            cpm_2 = null
            cpm_3 = null
            cpm_4 = null
            audience_1 = objectiveData.audiences[0]['audience']
            audience_2 = null
            audience_3 = null
            audience_4 = null
          if objectiveData.audiences.length is 2
            cpm_1 = objectiveData.audiences[0]['spend']/(objectiveData.audiences[0]['impressions']/1000)
            cpm_2 = objectiveData.audiences[1]['spend']/(objectiveData.audiences[1]['impressions']/1000)
            cpm_3 = null
            cpm_4 = null
            audience_1 = objectiveData.audiences[0]['audience']
            audience_2 = objectiveData.audiences[1]['audience']
            audience_3 = null
            audience_4 = null
          if objectiveData.audiences.length is 3
            cpm_1 = objectiveData.audiences[0]['spend']/(objectiveData.audiences[0]['impressions']/1000)
            cpm_2 = objectiveData.audiences[1]['spend']/(objectiveData.audiences[1]['impressions']/1000)
            cpm_3 = objectiveData.audiences[2]['spend']/(objectiveData.audiences[2]['impressions']/1000)
            cpm_4 = null
            audience_1 = objectiveData.audiences[0]['audience']
            audience_2 = objectiveData.audiences[1]['audience']
            audience_3 = objectiveData.audiences[2]['audience']
            audience_4 = null

          if objectiveData.audiences.length is 4
            cpm_1 = objectiveData.audiences[0]['spend']/(objectiveData.audiences[0]['impressions']/1000)
            cpm_2 = objectiveData.audiences[1]['spend']/(objectiveData.audiences[1]['impressions']/1000)
            cpm_3 = objectiveData.audiences[2]['spend']/(objectiveData.audiences[2]['impressions']/1000)
            cpm_4 = objectiveData.audiences[3]['spend']/(objectiveData.audiences[3]['impressions']/1000)
            audience_1 = objectiveData.audiences[0]['audience']
            audience_2 = objectiveData.audiences[1]['audience']
            audience_3 = objectiveData.audiences[2]['audience']
            audience_4 = objectiveData.audiences[3]['audience']

          audiencesChart.data.push([
            objectiveData.objective
            if audience_4 isnt null
              {v: "<div style='width: 180px; padding: 20px;'>" +
                  "<strong style='color: #424242'>" + objectiveData.objective + "</strong></span><br><br>" +
                  "<p style='font-size: 120%'><span style='color: #616161'><b> " + audience_1 + " Audience <br><span style='font-size: 200%; color:#1B9E77;'>" +   currencyFilter(cpm_1) + "<br></span></p>" +
                  "<p style='font-size: 120%'><span style='color: #616161'><b> " + audience_2 + " Audience <br><span style='font-size: 200%; color:#D95F02;'>" +   currencyFilter(cpm_2) + "<br></span></p>" +
                  "<p style='font-size: 120%'><span style='color: #616161'><b> " + audience_3 + " Audience <br><span style='font-size: 200%; color:#7570B3;'>" +   currencyFilter(cpm_3) + "<br></span></p>" +
                  "<p style='font-size: 120%'><span style='color: #616161'><b> " + audience_4 + " Audience <br><span style='font-size: 200%; color:#7570B3;'>" +   currencyFilter(cpm_4) + "<br></span></p>" +
                  "</div>", p: {}
              }
            else if audience_3 isnt null
              {v: "<div style='width: 180px; padding: 20px;'>" +
                  "<strong style='color: #424242'>" + objectiveData.objective + "</strong></span><br><br>" +
                  "<p style='font-size: 120%'><span style='color: #616161'><b> " + audience_1 + " Audience <br><span style='font-size: 200%; color:#1B9E77;'>" +   currencyFilter(cpm_1) + "<br></span></p>" +
                  "<p style='font-size: 120%'><span style='color: #616161'><b> " + audience_2 + " Audience <br><span style='font-size: 200%; color:#D95F02;'>" +   currencyFilter(cpm_2) + "<br></span></p>" +
                  "<p style='font-size: 120%'><span style='color: #616161'><b> " + audience_3 + " Audience <br><span style='font-size: 200%; color:#7570B3;'>" +   currencyFilter(cpm_3) + "<br></span></p>" +
                  "</div>", p: {}
              }
            else if audience_2 isnt null
              {v: "<div style='width: 180px; padding: 20px;'>" +
                  "<strong style='color: #424242'>" + objectiveData.objective + "</strong></span><br><br>" +
                  "<p style='font-size: 120%'><span style='color: #616161'><b> " + audience_1 + " Audience <br><span style='font-size: 200%; color:#1B9E77;'>" +   currencyFilter(cpm_1) + "<br></span></p>" +
                  "<p style='font-size: 120%'><span style='color: #616161'><b> " + audience_2 + " Audience <br><span style='font-size: 200%; color:#D95F02;'>" +   currencyFilter(cpm_2) + "<br></span></p>" +
                  "</div>", p: {}
              }
            else
              {v: "<div style='width: 180px; padding: 20px;'>" +
                  "<strong style='color: #424242'>" + objectiveData.objective + "</strong></span><br><br>" +
                  "<p style='font-size: 120%'><span style='color: #616161'><b> " + audience_1 + " Audience <br><span style='font-size: 200%; color:#1B9E77;'>" +   currencyFilter(cpm_1) + "<br></span></p>" +
                  "</div>", p: {}
              }
            cpm_1
            cpm_2
            cpm_3
            cpm_4
          ])

      audiencesChart.options =
        titleTextStyle: {color: '#797575' }
        displayExactValues: true
        is3D: true
        tooltip: {isHtml: true}
        animation: { startup: true, duration: 1000, easing: 'in' }
        focusTarget: 'category'
        legend: { position: 'bottom'}
        hAxis: { title: 'CPM', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575' }, format: 'currency'  }
        vAxis: { title: '', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'} }
        chartArea: {width: '70%', height: '75%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }
        colors: ['#1B9E77', '#D95F02', '#7570B3', '#3D5AFE']

      $scope.audiencesChart = audiencesChart

    createGenderChart = (genderData)->
      genderChart = {}
      genderChart.type = 'PieChart'
      genderChart.data = [
        [
         {type: 'string', label: 'Gender', p: {}}
         {type: 'string', label: 'Results', p: {}}
         {type: 'string', role: 'tooltip', p: {role: 'tooltip', html: true}}
        ]
      ]

      _.forEach genderData, (n) ->
        genderChart.data.push([
          n.gender_with_data
          n.results
          {v: "<div style='width: 160px; padding: 20px;'>" +
              "<strong style='color: #424242'>" + n.gender + "</strong></span><br><br>" +
                "<p style='font-size: 120%'><span style='color: #616161'><b>Results <br><span style='font-size: 200%; color:#616161;'>" + numberFilter(n.results) + "<br></span></p>" +
              "</div>", p: {}
          }
        ])

      genderChart.options =
        legend: 'none',
        pieSliceText: 'label',
        titleTextStyle: {color: '#797575' }
        displayExactValues: true
        tooltip: {isHtml: true}
        animation: { startup: true, duration: 1000, easing: 'in' }
        legend: { position: 'none'}
        hAxis: { title: '', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575' } }
        vAxis: { title: 'Results', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'} }
        chartArea: {width: '100%', height: '100%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }
        colors: ['#2196F3', '#F06292', '#BDBDBD']

      $scope.genderChart = genderChart

    createAgeChart = (ageData)->
      ageChart = {}
      ageChart.type = 'PieChart'

      ageChart.data = [
        [
         {type: 'string', label: 'Age'}
         {type: 'number', label: 'Results'}
         {type: 'string', role: 'tooltip', p: {role: 'tooltip', html: true}}
        ]
      ]

      _.forEach ageData, (data) ->
        ageChart.data.push([
          data['age_with_data']
          data['results']
          {v: "<div style='width: 160px; padding: 20px;'>" +
              "<strong style='color: #424242'>" + data['age'] + "</strong></span><br><br>" +
                "<p style='font-size: 120%'><span style='color: #616161'><b>Results <br><span style='font-size: 200%; color:#616161;'>" + numberFilter(data['results']) + "<br></span></p>" +
              "</div>", p: {}
          }
        ])

      ageChart.options =
        legend: 'none',
        pieSliceText: 'label',
        titleTextStyle: {color: '#797575' }
        displayExactValues: true
        tooltip: {isHtml: true}
        animation: { startup: true, duration: 1000, easing: 'in' }
        legend: { position: 'none'}
        hAxis: { title: '', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575' } }
        vAxis: { title: 'CPM', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'} }
        chartArea: {width: '100%', height: '100%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }
        colors: ['#80CBC4', '#4DB6AC', '#26A69A', '#009688', '#00897B', '#00796B']

      $scope.ageChart = ageChart

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
              "<p style='font-size: 120%'><span style='color: #616161'><b>Results <br><span style='font-size: 200%; color:#3366CC;'>" + numberFilter(data['results']) + "<br></span></p>" +
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
              "<p style='font-size: 120%'><span style='color: #616161'><b>Results <br><span style='font-size: 200%; color:#3366CC;'>" + numberFilter(data['results']) + "<br></span></p>" +
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
        vAxis: {title: 'CPM', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'}, format: 'currency'}
        chartArea: {width: '80%', height: '80%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }
        colors: ['#00838F']

      $scope.generalChartCPM = generalChartCPM

]
