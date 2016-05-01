@thesocialroute.factory 'Dashboard', [
  '$resource'

  ($resource) ->
    Dashboard = $resource '/dashboard/:id.json', id: '@id',
      index:
        method: 'GET'
        isArray: true
]
