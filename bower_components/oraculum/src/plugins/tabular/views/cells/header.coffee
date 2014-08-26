define [
  'oraculum'
  'oraculum/mixins/listener'
  'oraculum/mixins/disposable'
  'oraculum/views/mixins/attach'
  'oraculum/views/mixins/dom-cache'
  'oraculum/views/mixins/static-classes'
  'oraculum/views/mixins/html-templating'
  'oraculum/plugins/tabular/views/mixins/cell'
], (Oraculum) ->
  'use strict'

  ###
  Header.Cell
  ===========
  Like all other concrete implementations in Oraculum, this class exists as a
  convenience/example. Please feel free to override or simply not use this
  definition.
  ###

  Oraculum.extend 'View', 'Header.Cell', {

    events:
      'click a': '_sort'

    mixinOptions:
      staticClasses: ['header-cell-view']
      eventedMethods:
        render: {}
      listen:
        'render:after this': '_update'
        'change:label column': '_updateLabel'
        'change:sortable column': '_updateEnabled'
        'change:attribute column': '_updateLabel'
      template: '''
        <a href="javascript:void(0);" />
      '''

    _update: ->
      @_updateLabel()
      @_updateEnabled()

    _updateLabel: ->
      label = @column.get 'label'
      label ?= @column.get 'attribute'
      @$('a').text label

    _updateEnabled: ->
      sortable = Boolean @column.get 'sortable'
      @$('a').toggleClass 'disabled', not sortable

    _sort: ->
      return unless Boolean @column.get 'sortable'
      @column.nextDirection()

  }, mixins: [
    'Cell.ViewMixin'
    'Listener.Mixin'
    'Disposable.Mixin'
    'EventedMethod.Mixin'
    'StaticClasses.ViewMixin'
    'HTMLTemplating.ViewMixin'
  ]
