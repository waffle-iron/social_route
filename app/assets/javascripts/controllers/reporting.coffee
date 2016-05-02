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
      createGenderChart(reportingData.demographics.gender_breakdowns)
      createAgeChart(reportingData.demographics.age_breakdowns)
      createGeneralChart(reportingData.demographics.general_breakdowns)

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

    createGenderChart = (genderData)->
      genderChart = {}
      genderChart.type = 'PieChart'
      genderChart.data = [
        [
         {type: 'string', label: 'Male'}
         {type: 'string', label: 'Female'}
         {type: 'string', label: 'Unkown'}
        ]
      ]

      male =   _.map(_.filter(genderData, {gender: 'male'}), 'total_actions')[0]
      female = _.map(_.filter(genderData, {gender: 'female'}), 'total_actions')[0]
      unknown = _.map(_.filter(genderData, {gender: 'unknown'}), 'total_actions')[0]

      genderChart.data =
        'cols': [
          {
            id: 't'
            label: 'Gender'
            type: 'string'
          }
          {
            id: 's'
            label: 'Results'
            type: 'number'
          }
        ]
        'rows': [
          { c: [
            { v: 'Male' }
            { v: male }
          ] }
          { c: [
            { v: 'Female' }
            { v: female }
          ] }
          { c: [
            { v: 'Unknown' }
            { v: unknown }
          ] }
        ]

      genderChart.options =
        legend: 'none',
        pieSliceText: 'label',
        titleTextStyle: {color: '#797575' }
        displayExactValues: true
        animation: { startup: true, duration: 1000, easing: 'in' }
        legend: { position: 'none'}
        hAxis: { title: '', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575' } }
        vAxis: { title: 'CPM', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'} }
        chartArea: {width: '100%', height: '100%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }

      $scope.genderChart = genderChart

    createAgeChart = (ageData)->
      ageChart = {}
      ageChart.type = 'PieChart'

      ageChart.data = [
        [
         {type: 'string', label: 'Age'}
         {type: 'number', label: 'Results'}
        ]
      ]

      _.forEach ageData, (data) ->
        ageChart.data.push([
          data['age']
          data['total_actions']
        ])

      ageChart.options =
        legend: 'none',
        pieSliceText: 'label',
        titleTextStyle: {color: '#797575' }
        displayExactValues: true
        animation: { startup: true, duration: 1000, easing: 'in' }
        legend: { position: 'none'}
        hAxis: { title: '', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575' } }
        vAxis: { title: 'CPM', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'} }
        chartArea: {width: '100%', height: '100%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }

      $scope.ageChart = ageChart

    createGeneralChart = (generalData)->
      generalChart = {}
      generalChart.type = 'ColumnChart'
      generalChart.data = [
        [
         {type: 'string', label: 'Audience'}
         {type: 'number', label: 'Results'}
        ]
      ]

      audiences = _.uniq(_.map(generalData, 'audience'), 'audience')

      _.forEach audiences, (audience) ->
        generalChart.data.push([
          audience
          _.sumBy(_.filter(generalData, { 'audience': audience}), 'results')
        ])

      generalChart.options =
        titleTextStyle: {color: '#797575' }
        displayExactValues: true
        is3D: true
        animation: { startup: true, duration: 1000, easing: 'in' }
        legend: { position: 'none'}
        hAxis: { title: '', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575' } }
        vAxis: { title: 'Results', titleTextStyle: {color: '#797575' }, textStyle: {color: '#797575'} }
        chartArea: {width: '80%', height: '80%'}
        crosshair: { trigger: 'both', orientation: 'both', color: 'grey', opacity: 0.5 }

      $scope.generalChart = generalChart


]
