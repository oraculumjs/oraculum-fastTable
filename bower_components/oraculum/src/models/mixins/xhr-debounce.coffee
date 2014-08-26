define [
  'oraculum'
], (Oraculum) ->
  'use strict'

  Oraculum.defineMixin 'XHRDebounce.ModelMixin',

    mixinitialize: ->
      @on 'sync', @abortDebouncedXHR, this
      @on 'dispose', @abortDebouncedXHR, this
      @on 'request', (model, newRequest) =>
        return unless model is this
        @abortDebouncedXHR this
        @_debouncedXHR = newRequest

    abortDebouncedXHR: (model) ->
      return unless model is this
      @_debouncedXHR?.abort()
      delete @_debouncedXHR
