define [
  'oraculum'
], (Oraculum) ->
  'use strict'

  Oraculum.defineMixin 'StaticClasses.ViewMixin',

    mixinOptions:
      staticClasses: []

    mixinitialize: ->
      @$el.addClass @mixinOptions.staticClasses.join ' '
