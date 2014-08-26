define [
  'oraculum'
  'oraculum/mixins/evented'
  'oraculum/models/mixins/sort-by-attribute-direction-interface'
], (Oraculum) ->
  'use strict'

  Oraculum.defineMixin 'SortByAttributeDirection.CollectionMixin', {

    mixinitialize: ->
      @listenTo @sortState, 'change', _.debounce @sort, 10

    comparator: (a, b) ->
      attribute = @sortState.get 'attribute'
      direction = @sortState.get 'direction'

      if not attribute or not direction or
      not (valueA = a.get attribute)? or
      not (valueB = b.get attribute)?
        return a.cid > b.cid

      valueA = valueA.toString() if _.isFunction valueA.toString
      valueB = valueB.toString() if _.isFunction valueB.toString
      valueA = valueA.toLowerCase() if _.isFunction valueA.toLowerCase
      valueB = valueB.toLowerCase() if _.isFunction valueB.toLowerCase

      return a.cid > b.cid if valueA is valueB

      delta = -1 if valueA > valueB
      delta = 1 if valueA < valueB
      return delta * direction

  }, mixins: [
    'Evented.Mixin'
    'SortByAttributeDirectionInterface.CollectionMixin'
  ]
