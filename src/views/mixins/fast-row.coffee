define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/evented'
  'oraculum/views/mixins/static-classes'
  'oraculum/plugins/tabular/views/mixins/row'
], (Oraculum) ->
  'use strict'

  $ = Oraculum.get 'jQuery'
  _ = Oraculum.get 'underscore'

  defaultTemplate = ({model, column}) ->
    attr = column.get 'attribute'
    value = model.escape attr
    return "<div>#{value}</div>"

  Oraculum.define 'Oraculum-fastTable.Template', (-> defaultTemplate),
    singleton: true

  Oraculum.defineMixin 'FastRow.ViewMixin', {

    mixinOptions:
      list: { defaultTemplate }

    mixconfig: ({list}, {defaultTemplate} = {}) ->
      delete list.modelView
      list.defaultTemplate = defaultTemplate if defaultTemplate?

    initModelView: (column) ->
      model = @model or column

      template = column.get 'template'
      template or= @mixinOptions.list.defaultTemplate
      template = template {model, column} if _.isFunction template
      $template = $(template)

      view = {
        # Cell.ViewMixin interface
        model, column
        # Minimal Backbone.View interface
        el: $template[0]
        $el: $template
        render: -> this
      }

      factory = @__factory()
      options = @mixinOptions.list.viewOptions
      options = factory.composeConfig options, {model, column}
      options = options.call this, {model, column} if _.isFunction options

      # Automagically add Evented.Mixin
      templateMixins = _.chain(['Evented.Mixin'])
        .union(column.get 'templateMixins')
        .compact().uniq().value()

      mixins = factory.composeMixinDependencies templateMixins
      factory.enhanceObject factory, 'Oraculum-fastTable.Template', {mixins}, view
      factory.handleMixins view, mixins, [options]

      return view

  }, mixins: ['List.ViewMixin']
