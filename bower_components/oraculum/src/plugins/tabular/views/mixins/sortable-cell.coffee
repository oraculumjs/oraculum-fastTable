define [
  'oraculum'
  'oraculum/views/mixins/static-classes'
], (Oraculum) ->
  'use strict'

  ###
  Sortable.CellMixin
  ======================
  This mixin enhances the behavior of Cell.ViewMixin to provide sortable css
  class states on a cell based on its columns sort state.
  ###

  Oraculum.defineMixin 'Sortable.CellMixin', {

    mixinOptions:
      staticClasses: ['sortable-cell-mixin']

    mixinitialize: ->
      @column = @mixinOptions.cell.column
      @listenTo @column, 'change:sortable', @_updateSortableClass
      @listenTo @column, 'change:sortDirection', @_updateDirectionClass
      @_updateSortableClass()
      @_updateDirectionClass()

    _updateSortableClass: ->
      sortable = Boolean @column.get 'sortable'
      @$el.toggleClass 'sortable', sortable

    _updateDirectionClass: ->
      direction = @column.get 'sortDirection'
      @$el.toggleClass 'sorted', Boolean direction
      @$el.toggleClass 'ascending', direction is -1
      @$el.toggleClass 'descending', direction is 1

  }, mixins: ['StaticClasses.ViewMixin']
