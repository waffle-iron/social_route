@thesocialroute.controller 'OverviewCtrl', [
  '$scope'
  'Overview'
  '$filter'

  @OverviewCtrl = ($scope, Overview, $filter) ->
    numberFilter = $filter('number')
    currencyFilter = $filter('currency')

    Overview.index().$promise
    .then (overviewData) ->
      best_campaigns = []
      best_campaigns_ids = []

      _.forEach overviewData, (data) ->
        grouped_campaigns = _.groupBy(data.campaign_data, 'objective')

        _.forEach grouped_campaigns, (grouped_campaign) ->
          best_campaigns.push(_.minBy(grouped_campaign, 'score'))

      best_campaigns_ids = _.map best_campaigns, 'campaign_id'

      _.forEach overviewData, (data) ->
        _.forEach data.campaign_data, (campaign) ->
          if _.includes(best_campaigns_ids, campaign.campaign_id)
            campaign.best = 'yes'
          else
            campaign.best = 'no'

      $scope.overview = overviewData

]
