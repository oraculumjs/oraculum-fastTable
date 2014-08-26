define [
  'oraculum'
], (Oraculum) ->
  'use strict'

  Oraculum.defineMixin 'XHRCache.ModelMixin',

    mixinitialize: ->
      @_cachedXHRs = []
      @on 'sync', @_removeXHR, this
      @on 'request', @_cacheXHR, this

    _cacheXHR: (model, xhr) ->
      @_cachedXHRs.push xhr
      return @_cachedXHRs

    _removeXHR: (model, resp, {xhr}) ->
      index = @_cachedXHRs.indexOf xhr
      @_cachedXHRs.splice index, 1
      return @_cachedXHRs
