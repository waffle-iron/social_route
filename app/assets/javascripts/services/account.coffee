@thesocialroute.factory 'Account', [
  '$resource'

  ($resource) ->
    Account = $resource '/api/accounts/:id.json', id: '@id',
      index:
        method: 'GET'
        isArray: true
]
