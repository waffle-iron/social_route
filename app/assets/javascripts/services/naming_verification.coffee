@thesocialroute.factory 'NamingVerification', [
  '$resource'

  ($resource) ->
    NamingVerification = $resource '/api/naming_verification/:id.json', id: '@id',
      index:
        method: 'GET'
        isArray: false
]
