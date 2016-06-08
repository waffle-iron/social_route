@thesocialroute.controller 'ProfileCtrl', [
  '$scope'
  'Authentication'

  @ProfileCtrl = ($scope, Authentication) ->
    $scope.checkStatus = =>
      FB.getLoginStatus (response) ->
        if response.status == 'connected'
          console.log 'logged in'
        else if response.status == 'not_authorized'
          console.log 'not authorized'
        else
          console.log 'not logged in'

    $scope.Login = =>
      FB.login ((response) ->
        if response.authResponse
          getUserInfo()
          console.log response.authResponse.accessToken
        else
          console.log 'User cancelled login or did not fully authorize.'
      ),
        scope:  'email,basic_info,ads_read,ads_management'
        auth_type: 'rerequest'

    getUserInfo = ->
      FB.api "/me?fields=name,email,link", (response) ->
        console.log response
        str = '<b>Name</b> : ' + response.name + '<br>'
        str += '<b>Link: </b>' + response.link + '<br>'
        str += '<b>id: </b>' + response.id + '<br>'
        str += '<b>Email:</b> ' + response.email + '<br>'
        document.getElementById('status').innerHTML = str
      FB.api '/me/picture?type=normal', (response) ->
        str = '<img src=\'' + response.data.url + '\'/>'
        document.getElementById('status').innerHTML += str

      FB.api '/me/adaccounts', (response) ->
        console.log response

      FB.api '/me/permissions', (response) ->
        console.log response

    $scope.Logout = ->
      FB.logout (response) ->
        console.log response
        FB.Auth.setAuthResponse null, 'unknown'



]

    # User.get id: id, include: 'position,location,certifications'
    # .$promise.then (user) ->
    #   $scope.user = user
    #   _.each $scope.user.certifications, (cert) ->
    #     cert.certificationName = _.find(certificationNames, id: cert.certification_name_id)
