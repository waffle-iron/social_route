@thesocialroute.factory 'Reporting', [
  '$resource'

  ($resource) ->
    Reporting = $resource '/reporting/:id.json', id: '@id',
      index:
        method: 'GET'
        isArray: false
]
