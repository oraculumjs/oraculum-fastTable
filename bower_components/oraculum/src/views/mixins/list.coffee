define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/evented'
  'oraculum/mixins/evented-method'
  'oraculum/views/mixins/subview'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  subviewPrefix = 'modelView:'
  subviewName = ({cid}) -> "#{subviewPrefix}#{cid}"

  initModelView = (model) ->
    {modelView, viewOptions} = @mixinOptions.list
    throw new TypeError '''
      List.ViewMixin: The modelView mixin option must be defined or the
      initModelView() must be overridden.
    ''' unless modelView
    viewOptions = if _.isFunction viewOptions
    then viewOptions.call this, {model}
    else _.extend { model }, viewOptions
    return @createView { view: modelView, viewOptions }

  # A function that will be executed after each filter.
  # Hides excluded items by default.
  toggleView = (view, included) ->
    view.$el.stop true, true
    view.$el.css 'display', unless included then 'none' else ''

  Oraculum.defineMixin 'List.ViewMixin', {

    mixinOptions:
      list:
        filterer: null
        modelView: 'View'
        renderItems: true
        viewOptions: null
        listSelector: null
        viewSelector: undefined
        filterCallback: toggleView
      eventedMethods:
        render: {}

    mixconfig: ({list}, options = {}) ->
      {viewOptions, modelView} = options
      list.modelView = modelView if modelView?

      # Allow the viewOptions constructor arg to override our mixinOptions
      # viewOptions if it's a function, otherwise extend it as an object.
      # **Functions always win**
      list.viewOptions = viewOptions if _.isFunction viewOptions
      unless _.isFunction list.viewOptions
        list.viewOptions = _.extend {}, list.viewOptions, viewOptions

      {filterer, filterCallback} = options
      list.filterer = filterer if filterer?
      list.filterCallback = filterCallback if filterCallback?

      renderItems = options.renderItems
      list.renderItems = renderItems if renderItems?

      {listSelector, viewSelector} = options
      list.listSelector = listSelector if listSelector?
      list.viewSelector = viewSelector if viewSelector?

    mixinitialize: ->
      @visibleModels = []
      @initModelView ?= _.bind initModelView, this
      @listenTo @collection, 'add', @modelAdded
      @listenTo @collection, 'remove', @modelRemoved
      @listenTo @collection, 'reset sort', @renderAllModels
      @on 'render:after', @renderCollection, this

    modelAdded: (model, collection, {at:index}) ->
      view = @renderModel model
      @insertView model, view, index

    modelRemoved: (model) ->
      @updateVisibleModels model, false
      @removeSubview subviewName model

    renderCollection: ->
      {renderItems, listSelector} = @mixinOptions.list
      @_$list = if listSelector? then @$ listSelector  else @$el
      @renderAllModels() if renderItems

    renderAllModels: ->
      @visibleModels = []
      remainingViewsByName = {}
      models = @collection.models

      _.each models, (model) =>
        name = subviewName model
        return unless view = @subview name
        remainingViewsByName[name] = view

      _.each @_subviewsByName, (view, name) =>
        return unless 0 is name.indexOf subviewPrefix
        @removeSubview name unless name of remainingViewsByName

      _.each models, (model, index) =>
        name = subviewName model
        view = @subview name
        view ?= @renderModel model
        @insertView model, view, index

      @trigger 'visibilityChange', @visibleModels

    getModelViews: ->
      return _.chain(@_subviewsByName)
      .filter((view, name) -> 0 is name.indexOf subviewPrefix)
      .values().value()

    renderModel: (model) ->
      viewName = subviewName model
      view = @subview viewName
      view ?= @subview viewName, @initModelView model
      view.render()
      return view

    # Applies a filter to the collection view.
    # Expects an iterator function as first parameter
    # which need to return true or false.
    # Optional filter callback which is called to
    # show/hide the view or mark it otherwise as filtered.
    filter: (filterer, filterCallback) ->
      # Save the filterer and filterCallback functions.
      if filterer is null or _.isFunction filterer
        @mixinOptions.list.filterer = filterer

      if filterCallback is null or _.isFunction filterCallback
        @mixinOptions.list.filterCallback = filterCallback

      {filterer, filterCallback} = @mixinOptions.list

      hasItemViews = do =>
        if @_subviews.length > 0
          for name of @_subviewsByName when 0 is name.indexOf subviewPrefix
            return true
        return false

      # Show/hide existing views.
      if hasItemViews
        for model, index in @collection.models

          # Apply filter to the model.
          included = if _.isFunction filterer
          then filterer.call this, model, index
          else true

          # Show/hide the view accordingly.
          view = @subview subviewName model
          # A view has not been created for this model yet.
          throw new Error """
            List.ViewMixin#filter No view found for #{model.cid}
          """ unless view

          # Show/hide or mark the view accordingly.
          if _.isFunction filterCallback
            filterCallback.call this, view, included

          # Update visibleModels list, but do not trigger an event immediately.
          @updateVisibleModels model, included, false

      # Trigger a combined `visibilityChange` event.
      @trigger 'visibilityChange', @visibleModels

    insertView: (model, view, position) ->
      {filterer, filterCallback, viewSelector} = @mixinOptions.list

      included = true
      if _.isFunction filterer
        included = filterer.call this, model, position
        filterCallback.call this, view, included if _.isFunction filterCallback

      # Use .css instead of .toggle to avoid jquery's assumptions
      # about what display mode an element should have
      toggleView view, included

      length = @collection.length
      position = @collection.indexOf model unless _.isNumber position

      insertInMiddle = (0 < position < length)
      isEnd = (length) -> length in [0, position]

      if insertInMiddle or viewSelector
        children = @_$list.children viewSelector
        if children[position] isnt view.el
          childrenLength = children.length
          if isEnd childrenLength
          then @_$list.append view.el
          else if position is 0
          then children.eq(position).before view.el
          else children.eq(position - 1).after view.el
      else
        method = 'prepend'
        method = 'append' if isEnd length
        @_$list[method] view.el

      view.trigger 'addedToParent'
      @updateVisibleModels model, included

      return view

    updateVisibleModels: (model, includedInFilter, triggerEvent = true) ->
      visibilityChanged = false
      visibleModelsIndex = @visibleModels.indexOf model
      includedInVisibleItems = visibleModelsIndex isnt -1

      if includedInFilter and not includedInVisibleItems
        @visibleModels.push model
        visibilityChanged = true
      else if not includedInFilter and includedInVisibleItems
        @visibleModels.splice visibleModelsIndex, 1
        visibilityChanged = true

      if visibilityChanged and triggerEvent
        @trigger 'visibilityChange', @visibleModels

      return visibilityChanged

  }, mixins: [
    'Evented.Mixin'
    'Subview.ViewMixin'
    'EventedMethod.Mixin'
  ]
