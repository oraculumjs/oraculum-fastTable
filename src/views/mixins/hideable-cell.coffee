define [
  'oraculum'
], (Oraculum) ->
  'use strict'

  Oraculum.defineMixin 'Hideable.CellTemplateMixin',

    mixinitialize: ->
      @addClass 'hideable-cell-mixin'
      @toggle not @data('column').get 'hidden'
