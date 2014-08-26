define [
  'oraculum'
  'oraculum/mixins/evented'
  'oraculum/mixins/disposable'
], (Oraculum) ->
  'use strict'

  stateModelName = '_SortByAttributeDirectionInterfaceState.Model'
  Oraculum.extend 'Model', stateModelName, {
    idAttribute: 'attribute'

    validate: ({attribute, direction}) ->
      return "'attribute' attribute required" unless attribute
      return "'direction' attribute required" unless direction
      return "Invalid direction: '#{direction}'" unless direction in [-1, 1]

  }, mixins: [
    'Disposable.Mixin'
  ]

  Oraculum.defineMixin 'SortByAttributeDirectionInterface.CollectionMixin', {

    mixinOptions:
      sortByAttributeDirection:
        defaults: {}

    mixconfig: ({sortByAttributeDirection}, models, {sortDefaults} = {}) ->
      sortByAttributeDirection.defaults = sortDefaults if sortDefaults?

    mixinitialize: ->
      defaults = @mixinOptions.sortByAttributeDirection.defaults
      @sortState = @__factory().get stateModelName, defaults
      @on 'dispose', (target) =>
        return unless target is this
        @sortState.dispose()
        delete @sortState

    addAttributeDirection: (attribute, direction) ->
      return @unsort() unless direction
      @sortState.set {attribute, direction}

    getAttributeDirection: (attribute) ->
      return 0 unless attribute is @sortState.get 'attribute'
      return @sortState.get 'direction'

    # For a single attribute/direction sorting mechanism, removing the current
    # attribute and clearing the sort state completely are functionally the same
    removeAttributeDirection: -> @unsort()
    unsort: -> @sortState.unset {'attribute', 'direction'}

  }, mixins: [
    'Evented.Mixin'
  ]
