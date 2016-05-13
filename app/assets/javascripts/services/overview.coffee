@thesocialroute.factory 'Overview', [
  '$resource'

  ($resource) ->
    Overview = $resource '/api/overview/:id.json', id: '@id',
      index:
        method: 'GET'
        isArray: true
]
