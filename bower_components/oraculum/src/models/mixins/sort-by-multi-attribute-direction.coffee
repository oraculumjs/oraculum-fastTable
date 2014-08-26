define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/evented'
  'oraculum/models/mixins/sort-by-multi-attribute-direction-interface'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  multiDirectionSort = (a, b, attributes, directions, index = 0) ->
    return 0 if (direction = directions[index]) is 0

    attribute = attributes[index]
    return 0 unless (valueA = a.get attribute)?
    return 0 unless (valueB = b.get attribute)?

    # Normalize our input
    valueA = valueA.toString() if _.isFunction valueA.toString
    valueB = valueB.toString() if _.isFunction valueB.toString
    valueA = valueA.toLowerCase() if _.isFunction valueA.toLowerCase
    valueB = valueB.toLowerCase() if _.isFunction valueB.toLowerCase

    if valueA is valueB
      return if (attributes.length - 1) is index then 0
      else multiDirectionSort a, b, attributes, directions, ++index

    return direction if valueA < valueB
    return direction * -1

  Oraculum.defineMixin 'SortByMultiAttributeDirection.CollectionMixin', {

    mixinitialize: ->
      @listenTo @sortState, 'add remove reset change', _.debounce @sort, 10

    comparator: (a, b) ->
      attributes = @sortState.pluck 'attribute'
      directions = @sortState.pluck 'direction'
      return (a.cid > b.cid) and 1 or -1 unless attributes.length
      return multiDirectionSort a, b, attributes, directions

  }, mixins: [
    'Evented.Mixin'
    'SortByMultiAttributeDirectionInterface.CollectionMixin'
  ]
