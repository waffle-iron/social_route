@thesocialroute.controller 'OverviewAdsetCtrl', [
  '$scope'
  'OverviewAdsets'
  '$filter'
  '$location'

  @OverviewAdsetCtrl = ($scope, OverviewAdsets, $filter, $location) ->
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

    OverviewAdsets.index(account_id: getParameterByName('account_id')).$promise
    .then (overviewAdsetData) ->
      # best_campaigns = []
      # best_campaigns_ids = []
      #
      # _.forEach overviewData, (data) ->
      #   grouped_campaigns = _.groupBy(data.campaign_data, 'objective')
      #
      #   _.forEach grouped_campaigns, (grouped_campaign) ->
      #     best_campaigns.push(_.minBy(grouped_campaign, 'score'))
      #
      # best_campaigns_ids = _.map best_campaigns, 'campaign_id'
      #
      # _.forEach overviewData, (data) ->
      #   _.forEach data.campaign_data, (campaign) ->
      #     if _.includes(best_campaigns_ids, campaign.campaign_id)
      #       campaign.best = 'yes'
      #     else
      #       campaign.best = 'no'

      $scope.overviewAdsets = overviewAdsetData
      console.log $scope.overviewAdsets
]
