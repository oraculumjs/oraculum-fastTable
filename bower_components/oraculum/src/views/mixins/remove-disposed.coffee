define [
  'oraculum'
  'oraculum/mixins/evented'
], (Oraculum) ->
  'use strict'

  Oraculum.defineMixin 'RemoveDisposed.ViewMixin', {
    mixinOptions:
      disposable:
        keepElement: false

    mixconfig: ({disposable}, {keepElement} = {}) ->
      disposable.keepElement = keepElement if keepElement?

    mixinitialize: ->
      @on 'dispose', =>
        keepElement = @mixinOptions.disposable.keepElement
        @remove() unless keepElement is true

  }, mixins: [
    'Evented.Mixin'
  ]
