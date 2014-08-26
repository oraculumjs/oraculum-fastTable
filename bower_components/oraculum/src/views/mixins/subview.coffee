define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/evented-method'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  Oraculum.defineMixin 'Subview.ViewMixin', {

    # Example subviews configuration
    # ------------------------------
    # ```coffeescript
    # mixinOptions:
    #   subviews:
    #     nameOfChildView:
    #       view: 'View'
    #       viewOptions: {}
    #     nameOfAnotherChildView: ->
    #       view: @view
    #       viewOptions: @getViewOptions()
    # ```

    mixinOptions:
      eventedMethods:
        render: {}

    mixconfig: (mixinOptions, {subviews} = {}) ->
      mixinOptions.subviews = _.extend {}, mixinOptions.subviews, subviews

    mixinitialize: ->
      @_subviews = []
      @_subviewsByName = {}
      @on 'render:after', @createSubviews, this
      @on 'dispose', => _.each @_subviews, (view) -> view.dispose?()

    createSubviews: ->
      _.each @mixinOptions.subviews, (spec, name) =>
        @createSubview name, spec

    createSubview: (name, spec) ->
      return @subview name, @createView spec

    createView: (spec) ->
      spec = spec.call this if _.isFunction spec
      viewOptions = _.extend {}, spec.viewOptions
      return if _.isString spec.view
      then @__factory().get spec.view, viewOptions
      else new spec.view viewOptions

    subview: (name, view) ->
      return @_subviewsByName[name] unless view
      @removeSubview name
      @_subviews.push view
      @_subviewsByName[name] = view
      @trigger 'subviewCreated', view, this
      return view

    removeSubview: (nameOrView) ->
      if _.isString nameOrView
        name = nameOrView
        view = @_subviewsByName[name]
      else
        view = nameOrView
        for otherName in @_subviewsByName
          otherView = @_subviewsByName[otherName]
          if view is otherView
            name = otherName
            break
      return unless name and view
      view.remove()
      view.dispose?()
      index = @_subviews.indexOf view
      @_subviews.splice index, 1 unless index is -1
      return delete @_subviewsByName[name]

  }, mixins: [
    'EventedMethod.Mixin'
  ]
