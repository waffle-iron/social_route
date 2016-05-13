@thesocialroute.factory 'Dashboard', [
  '$resource'

  ($resource) ->
    Dashboard = $resource '/api/dashboard/:id.json', id: '@id',
      index:
        method: 'GET'
        isArray: true
]
