define [
  'oraculum'
  'oraculum/mixins/listener'
  'oraculum/mixins/disposable'
  'oraculum/views/mixins/static-classes'
  'oraculum/views/mixins/html-templating'
  'oraculum/views/mixins/dom-property-binding'
  'oraculum/plugins/tabular/views/mixins/cell'
], (Oraculum) ->
  'use strict'

  ###
  Text.Cell
  =========
  Like all other concrete implementations in Oraculum, this class exists as a
  convenience/example. Please feel free to override or simply not use this
  definition.
  ###

  Oraculum.extend 'View', 'Text.Cell', {

    mixinOptions:
      staticClasses: ['text-cell-view']
      listen:
        'change:attribute column': 'render'
        'change:display_attribute column': 'render'
      template: ->
        attribute = @column.get 'display_attribute'
        attribute ?= @column.get 'attribute'
        return "<span data-prop='model' data-prop-attr='#{attribute}'/>"

  }, mixins: [
    'Cell.ViewMixin'
    'Listener.Mixin'
    'Disposable.Mixin'
    'StaticClasses.ViewMixin'
    'HTMLTemplating.ViewMixin'
    'DOMPropertyBinding.ViewMixin'
  ]
