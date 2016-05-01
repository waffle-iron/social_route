@thesocialroute.controller 'DashboardCtrl', [
  '$scope'
  'Dashboard'

  @DashboardCtrl = ($scope, Dashboard) ->
    Dashboard.index().$promise
    .then (dashboardData) ->
      _.forEach dashboardData, (account) ->
        account.statusCodeValue = statusCodeLookup(account.account_status)

      $scope.accounts = dashboardData

    statusCodeLookup = (code) ->
      switch code
        when "1" then "ACTIVE"
        when "2" then "DISABLED"
        when "3" then "UNSETTLED"
        when "7" then "PENDING_RISK_REVIEW"
        when "9" then "IN_GRACE_PERIOD"
        when "100" then "PENDING_CLOSURE"
        when "101" then "CLOSED"
        when "102" then "PENDING_SETTLEMENT"
        when "201" then "ANY_ACTIVE"
        when "202" then "ANY_CLOSED"
        else "ERROR"
]
