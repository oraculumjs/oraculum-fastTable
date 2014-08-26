define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/evented'
  'oraculum/mixins/evented-method'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  # This mixin allows you to bind values of arbitrary properties on the view to
  # dom elements, loosely based on MVVM patterns and AngularJS
  #
  # Examples
  # --------
  # This element will have its text content set to the name attribute of @model
  # An event listener will be created for change:name events on @model which
  # will update this elements text content whenever the event is fired.
  # ```html
  # <div data-prop="model" data-prop-attr="name" />
  # ```
  #
  # This scenario is the same as the previous one, however this will register a
  # change:nickname event listener on @model.metadata assuming it has the 'on'
  # method.
  # ```html
  # <div data-prop="model.metadata" data-prop-attr="nickname" />
  # ```
  #
  # Again, this scenario is the same as above, but instead of attempting to
  # register a change:nickname listener for @model.metadata, a listener will be
  # created for change:metadata events on @model.
  # ```html
  # <div data-prop="model" data-prop-attr="metadata.nickname" />
  # ```
  #
  # This element will be bound to the length property of @model.collection.
  # Because the data-prop attribute points to a collection, the mixin will
  # register an event listener for add, remove, reset events on the collection.
  # ```html
  # <div data-prop="model.collection" data-prop-attr="length" />
  # ```

  Oraculum.defineMixin 'DOMPropertyBinding.ViewMixin', {

    mixinOptions:
      domPropertyBinding:
        placeholder: '...'
      eventedMethods:
        render: {}

    # Mixconfig
    # ---------
    # Expose the placeholder constructor arg

    mixconfig: ({domPropertyBinding}, {placeholder} = {}) ->
      domPropertyBinding.placeholder = placeholder if placeholder?

    # Mixinitialize
    # -------------
    # Gets invoked automagically after initialization.

    mixinitialize: ->
      # Invoke our _bindElements method when the view renders
      @on 'render:after', @_bindElements, this

    # Bind Elements
    # -------------
    # Iterate over all elements that match our data-attribute convention and
    # add an event listener to its target property.

    _bindElements: ->
      $elements = @$ '[data-prop][data-prop-attr]'
      _.each $elements, (element) =>
        $element = $ element
        propertySpec = $element.attr('data-prop').split '.'
        resolvedProperty = @_resolveProperty this, propertySpec
        if tags = resolvedProperty.__tags?()
          @_bindToModel element, resolvedProperty if 'Model' in tags
          @_bindToCollection element, resolvedProperty if 'Collection' in tags
        @_updateBoundElement element

    # Resolve Property
    # ----------------
    # Take a context and an array of strings representing cascading
    # sub-properties of that context and recursively step into the object
    # looking for the sub properties named in the array. Will attempt to
    # access the sub-property via the .get interface if available and fall back
    # to access via object/array index.

    _resolveProperty: (context, attributes, index = 0) ->
      attribute = attributes[index]
      property = context.get attribute if _.isFunction context.get
      property ?= _.result context, attribute
      return null unless property?
      return property if index is attributes.length - 1
      return @_resolveProperty property, attributes, ++index

    # Bind Element to Model
    # ---------------------
    # Binds model events to our update function.

    _bindToModel: (element, model) ->
      $element = @validateBindTarget element
      attr = $element.attr('data-prop-attr').split('.')[0]
      events = $element.attr 'data-prop-events'
      events ?= "change:#{attr}"
      @listenTo model, events, @_getElementHandler element if events

    # Bind Element to Collection
    # --------------------------
    # Binds collection events to our update function.

    _bindToCollection: (element, collection) ->
      $element = @validateBindTarget element
      events = $element.attr 'data-prop-events'
      events ?= 'add remove reset'
      @listenTo collection, events, @_getElementHandler element if events

    # Validate Bind Target
    # --------------------
    # Validate that a given element, wrapped element, or selector is found in
    # this view's element and matches our data-attribute convention.
    # Return a wrapped element if it does.

    validateBindTarget: (element) ->
      $element = @$ element
      throw new Error """
        #{element} not found in #{this} scope
      """ unless $element.length
      throw new Error """
        #{element} does not contain necessary data attributes
      """ unless $element.is '[data-prop][data-prop-attr]'
      return $element

    # Bound Element Handler
    # ---------------------
    # Returns a function that invokes @_updateBoundElement with a reference to
    # the bound element.

    _getElementHandler: (element) ->
      @validateBindTarget element
      return => @_updateBoundElement element

    # Update Bound Element
    # --------------------
    # Accepts an element, jquery wrapped element, or a selector for selecting
    # a data-bound element in scope of this view's @$el and updates its content
    # with the value prescribed by the elements data-prop attributes.

    _updateBoundElement: (element) ->
      $element = @validateBindTarget element
      propertySpec = $element.attr('data-prop').split '.'
      resolvedProperty = @_resolveProperty this, propertySpec
      throw new Error """
        View does not contain property #{prop}
      """ unless resolvedProperty?
      attrSpec = $element.attr('data-prop-attr').split '.'
      resolvedAttr = @_resolveProperty resolvedProperty, attrSpec
      attribute = resolvedAttr if resolvedAttr?
      attribute ?= $element.attr 'data-prop-placeholder'
      attribute ?= @mixinOptions.domPropertyBinding.placeholder
      method = $element.attr('data-prop-method') or 'text'
      $element[method] attribute

  }, mixins: [
    'Evented.Mixin'
    'EventedMethod.Mixin'
  ]
