define [
  'oraculum'
  'oraculum/mixins/evented'
], (Oraculum) ->
  'use strict'

  Oraculum.defineMixin 'VariableWidth.CellTemplateMixin', {

    mixinitialize: ->
      @addClass 'variable-width-cell-mixin'
      column = @data 'column'
      @listenTo column, 'change:width', =>
        @_updateWidth column
      @_updateWidth column

    _updateWidth: (column) ->
      return unless (width = column.get 'width')?
      @css {width}

  }, mixins: ['Evented.Mixin']
