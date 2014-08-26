define [
  'oraculum'
  'oraculum/mixins/evented'
  'oraculum/mixins/evented-method'
], (Oraculum) ->
  'use strict'

  Oraculum.defineMixin 'LastFetch.ModelMixin', {

    mixinOptions:
      eventedMethods:
        fetch: {}

    mixinitialize: ->
      @on 'fetch:before', =>
        @_lastFetchedAt = new Date()

    lastFetch: -> @_lastFetchedAt
    hasFetched: -> Boolean @_lastFetchedAt

  }, mixins: [
    'Evented.Mixin'
    'EventedMethod.Mixin'
  ]
