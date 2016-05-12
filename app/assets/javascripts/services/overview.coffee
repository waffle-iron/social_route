@thesocialroute.factory 'Overview', [
  '$resource'

  ($resource) ->
    Overview = $resource '/overview/:id.json', id: '@id',
      index:
        method: 'GET'
        isArray: true
]
