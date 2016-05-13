@thesocialroute.factory 'Reporting', [
  '$resource'

  ($resource) ->
    Reporting = $resource '/api/reporting/:id.json', id: '@id',
      index:
        method: 'GET'
        isArray: false
]
