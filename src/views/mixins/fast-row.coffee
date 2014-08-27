define [
  'oraculum'
  'oraculum/libs'
  'oraculum/views/mixins/static-classes'
], (Oraculum) ->
  'use strict'

  $ = Oraculum.get 'jQuery'

  Oraculum.defineMixin 'FastRow.ViewMixin', {

    mixinOptions:
      staticClasses: ['fast-row-mixin']

    mixinitialize: ->
      debouncedRender = _.debounce => @render()
      @listenTo @model, 'all', debouncedRender
      @listenTo @collection, 'change', debouncedRender
      @listenTo @collection, 'add remove reset sort', => @render()

    render: ->
      @$el.empty()
      @collection.each (column) =>
        $template = @_getTemplate column
        @$el.append $template
      return this

    _getTemplate: (column) ->
      template = column.get 'template'
      template = template {@model, column} if _.isFunction template

      value = @model.escape column.get 'attribute'
      template or= "<div>#{value}</div>"

      $template = $(template)
      $template.data {@model, column}

      if templateMixins = column.get 'templateMixins'
        @__factory().handleMixins $template, templateMixins, {@model, column}

      return $template

  }, mixins: ['StaticClasses.ViewMixin']
