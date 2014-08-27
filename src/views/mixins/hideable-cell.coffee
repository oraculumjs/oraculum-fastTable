define [
  'oraculum'
], (Oraculum) ->
  'use strict'

  Oraculum.defineMixin 'Hideable.CellTemplateMixin',

    mixinitialize: ->
      @addClass 'hideable-cell-template-mixin'
      @toggle not @data('column').get 'hidden'
