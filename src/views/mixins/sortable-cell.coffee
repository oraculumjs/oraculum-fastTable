define [
  'oraculum'
], (Oraculum) ->
  'use strict'

  Oraculum.defineMixin 'Sortable.CellTemplateMixin',

    mixinitialize: ->
      @addClass 'sortable-cell-template-mixin'
      @_updateSortableClass()
      @_updateDirectionClass()

    _updateSortableClass: ->
      sortable = Boolean @data('column').get 'sortable'
      @toggleClass 'sortable', sortable

    _updateDirectionClass: ->
      direction =  @data('column').get 'sortDirection'
      @toggleClass 'sorted', Boolean direction
      @toggleClass 'ascending', direction is -1
      @toggleClass 'descending', direction is 1
