define [
  'oraculum'
  'oraculum/mixins/evented'
  'oraculum/views/mixins/static-classes'
  'oraculum/plugins/tabular/views/mixins/sortable-cell'
  'oraculum/plugins/tabular/views/mixins/hideable-cell'
], (Oraculum) ->
  'use strict'

  ###
  Cell.ViewMixin
  ==============
  A "cell" is the intersection of a "column" and a "row".
  In a common tabular view, a "row" may represent a data model,
  and a "column" may represent a rendering specification for the data.
  E.g. what attribute of the data model the cell should render.
  This mixin aims to cover the most common use cases for tabular view cells.
  ###

  Oraculum.defineMixin 'Cell.ViewMixin', {

    mixinOptions:
      staticClasses: [
        'cell' # TODO: 'cell' should be removed prior to 2.0
        'cell-mixin'
      ]
      cell: column: null

    mixconfig: ({cell}, {model, column} = {}) ->
      cell.column = column if column?
      cell.column ?= model if model?
      throw new Error '''
        Cell.ViewMixin#mixconfig: requires a column
      ''' unless cell.column

    mixinitialize: ->
      @column = @mixinOptions.cell.column
      @listenTo @column, 'change:attribute', @_updateAttributeClass
      @_updateAttributeClass()

    _updateAttributeClass: ->
      previous = @column.previous 'attribute'
      @$el.removeClass "#{previous}-cell".replace /[\.\s]/, '-'
      current = @column.get 'attribute'
      @$el.addClass "#{current}-cell".replace /[\.\s]/, '-'

  }, mixins: [
    'Evented.Mixin'
    'Hideable.CellMixin'
    'Sortable.CellMixin'
    'StaticClasses.ViewMixin'
  ]
