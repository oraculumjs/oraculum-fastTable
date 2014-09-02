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

  Oraculum.defineMixin 'FastRow.ViewMixin', {

    mixinOptions:
      staticClasses: ['fast-row-mixin']
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
        model, column,
        el: $template[0]
        $el: $template
        render: -> view
      }

      viewOptions = @mixinOptions.list.viewOptions
      viewOptions = _.extend {model, column}, viewOptions

      templateMixins = _.chain(['Evented.Mixin'])
        .union(column.get 'templateMixins')
        .compact().uniq().value()
      @__factory().handleMixins view, templateMixins, [viewOptions]

      return view

  }, mixins: [
    'List.ViewMixin'
    'StaticClasses.ViewMixin'
  ]
