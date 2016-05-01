@thesocialroute.controller 'ReportingCtrl', [
  '$scope'
  'Reporting'

  @DashboardCtrl = ($scope, Reporting) ->
    Reporting.index().$promise
    .then (reportingData) ->
      _.forEach reportingData.overview, (objective) ->
        objective.CPM = (objective.impressions/objective.spend)/1000
        objective.CRR = objective.total_actions/objective.spend

      $scope.reporting = reportingData
      createCpmChart(reportingData.cpm_placement)
      createAudiencesChart(reportingData.audiences)

    createCpmChart = (cpmData)->
      cpmChart = {}
      cpmChart.type = 'ColumnChart'
      cpmChart.data = [
        [
         {type: 'string', label: 'Placement'}
         {type: 'number', label: 'CPM'}
        ]
      ]

      _.forEach cpmData, (n) ->

        cpmChart.data.push([
          n.placement
          n.cpm
        ])

      cpmChart.options =
        titleTextStyle: {color: '#797575' }
        displayExactValues: true
        is3D: true
        animation: { startup: true, duration: 1000, easing: 'in' }
        legend: { position: 'none'}
        hAxis: { title: '', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575' } }
        vAxis: { title: 'CPM', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'} }
        chartArea: {width: '80%', height: '80%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }

      $scope.cpmChart = cpmChart

    createAudiencesChart = (audienceData)->
      audiencesChart = {}
      audiencesChart.type = 'BarChart'

      objectives = _.uniq(_.map(_.sortBy(audienceData, 'objective'), 'objective'))

      audiencesChart.data = [
        [
         {type: 'string', label: 'Audience'}
         {type: 'number', label: 'CPM Audience #1'}
         {type: 'number', label: 'CPM Audience #2'}
         {type: 'number', label: 'CPM Audience #3'}
        ]
      ]

      _.forEach objectives, (n) ->
        audiences = _.filter(audienceData, { 'objective': n})
        console.log audiences

        if audiences.length is 1
          audiencesChart.data.push([
            n
            audienceData[0].cpm
            null
            null
          ])

        if audiences.length is 2
          audiencesChart.data.push([
            n
            audienceData[0].cpm
            audienceData[1].cpm
            null
          ])

        if audiences.length is 3
          audiencesChart.data.push([
            n
            audienceData[0].cpm
            audienceData[1].cpm
            audienceData[2].cpm
          ])

      audiencesChart.options =
        titleTextStyle: {color: '#797575' }
        displayExactValues: true
        is3D: true
        animation: { startup: true, duration: 1000, easing: 'in' }
        legend: { position: 'none'}
        hAxis: { title: 'CPM', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575' } }
        vAxis: { title: '', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'} }
        chartArea: {width: '60%', height: '80%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }

      $scope.audiencesChart = audiencesChart

]
