define [
  'oraculum'
  'oraculum/mixins/evented'
], (Oraculum) ->
  'use strict'

  Oraculum.defineMixin 'VariableWidth.CellTemplateMixin', {

    mixinitialize: ->
      @addClass 'variable-width-cell-template-mixin'
      column = @data 'column'
      updateWidth = => @_updateWidth column
      @listenTo column, 'change:width', updateWidth
      updateWidth()

    _updateWidth: (column) ->
      return unless (width = column.get 'width')?
      @css {width}

  }, mixins: ['Evented.Mixin']
