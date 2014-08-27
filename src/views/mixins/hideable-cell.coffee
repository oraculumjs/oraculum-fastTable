define [
  'oraculum'
], (Oraculum) ->
  'use strict'

  Oraculum.defineMixin 'Hideable.CellTemplateMixin',

    mixinitialize: ->
      @addClass 'hideable-cell-template-mixin'
      hidden = @data('column').get 'hidden'
      display = if Boolean hidden then 'none' else ''
      @css {display}
