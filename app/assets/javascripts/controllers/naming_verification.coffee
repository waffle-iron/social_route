@thesocialroute.controller 'NamingVerificationCtrl', [
  '$scope'
  'NamingVerification'
  'Account'

  @NamingVerificationCtrl = ($scope, NamingVerification, Account) ->
    Account.index().$promise
    .then (accountData) ->
      accounts = accountData

      NamingVerification.index().$promise
      .then (namingVerificationData) ->
        _.forEach namingVerificationData.campaigns, (campaign) ->
          campaign.accountName = _.map(_.filter(accounts, { 'account_id': 'act_' + campaign.account_id }), 'name')[0]

        _.forEach namingVerificationData.adsets, (adset) ->
          adset.accountName = _.map(_.filter(accounts, { 'account_id': adset.account_id }), 'name')[0]

        _.forEach namingVerificationData.ads, (ad) ->
          ad.accountName = _.map(_.filter(accounts, { 'account_id': 'act_' + ad.account_id }), 'name')[0]

        $scope.namingVerificationData = namingVerificationData

]
