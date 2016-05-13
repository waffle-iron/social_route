@thesocialroute.factory 'OverviewAdsets', [
  '$resource'

  ($resource) ->
    OverviewAdsets = $resource '/api/overview/adsets/:id.json', id: '@id',
      index:
        method: 'GET'
        isArray: true
]
