define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/pub-sub'
  'oraculum/mixins/listener'
  'oraculum/mixins/disposable'
  'oraculum/mixins/callback-provider'
  'oraculum/application/composition'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  ###
  Composer
  ========
  The sole job of the composer is to manage the lifecycle of `View`s across
  `Controller` actions. If a `View` has already been composed by a previous
  action then nothing apart from registering the `View` as in-use happens.
  Otherwise, the `View` is constructed with the specified `options`.
  If the application is routed to an action where the `View` was not composed,
  the `View` will disposed.

  @see application/controller.coffee
  @see http://backbonejs.org/#View
  ###

  Oraculum.define 'Composer', (class Composer

    ###
    Compositions
    ------------
    This is the collection of composed compositions.

    @see application/composition.coffee

    @type {Object}
    ###

    compositions: null


    ###
    Constructor
    -----------
    Initialize `@compositions` as a new blank object, and allow custom
    initialization via the standard `initialize` method.
    ###

    constructor: ->
      # Set `@compositions` to a bare object.
      @compositions = {}
      # Invoke `@initialize` if it's available.
      @initialize? arguments...

    ###
    Mixin Options
    -------------
    Set up our event listeners and named callbacks.

    @see mixins/listener.coffee
    @see mixins/callback-provider.coffee
    ###

    mixinOptions:
      listen:
        'dispose this': '_disposeCompositions'
        'dispatcher:dispatch mediator': '_cleanup'
      provideCallbacks:
        'composer:compose': 'compose'
        'composer:retrieve': 'retrieve'

    ###
    Retrieve
    --------
    Retrieve an active `composition`'s `item` from our `compositions` collector.
    Will return `undefined` if the named composition doesn't exist, or is stale.

    @param {String} name Name of the composition to be retrieved

    @return {Composition} If composition `name` exists and is not stale.
    ###

    retrieve: (name) ->
      active = @compositions[name]
      return unless active
      return if active.stale()
      return active.item

    ###
    Compose
    -------
    Constructs a composition and adds it into the active compositions.
    This function permits numerous fingerprints. See comments for details.

    @see @_composeWithComposition
    @see @_composeWithDefinition
    @see @_composeWithFunction
    @see @_composeWithFunctionAndOptions
    @see @_composeWithOptions

    @param {String} name The name of the composition to compose.
    @param {Function} second?
    @param {Object} second?
    @param {Function} third?
    @param {Object} third?
    ###

    compose: (name, second, third) ->
      if _.isFunction(second) or _.isString(second)

        Composition = @__factory().getConstructor 'Composition'
        if second.prototype instanceof Composition
          return @_composeWithComposition name, second, third

        if third or
        _.isString(second) or
        second.prototype isnt Function.prototype
          return @_composeWithDefinition name, second, third

        return @_composeWithFunction name, second

      if _.isFunction third
        return @_composeWithFunctionAndOptions name, third, second

      return @_composeWithOptions name, second


    #### Compose With Composition ###
    ###
    Composes with a `Composition` object.
    This method gives complete control over the composition process.

    @param {String} name The name of the composition to compose.
    @param {Composition} composition The constructed composition to register.
    @param {Object} options The options to be passed to the `composition`.
    ###

    _composeWithComposition: (name, composition, options) ->
      @_compose name, { composition, options }


    #### Compose With Definition ###
    ###
    Composes a `View` or a factory definition name.
    The options are passed to the instance when it is constructed and are
    further used to test if the `composition` should be re-composed.

    @param {String} name The name of the composition to compose.
    @param {Constructor} definition Constructor that the `composition` should create.
    @param {String} definition Factory definition that the `composition` should create.
    @param {Object} options The options to be passed to the `composition`.
    ###

    _composeWithDefinition: (name, definition, options = {}) ->
      @_compose name,
        options: options
        compose: ->
          @item = if _.isString definition
          then @__factory().get definition, @options
          else new definition @options

    #### Compose With Function ###
    ###
    Composes a function that executes in the context of the `Controller`.
    It __does not__ bind the function context.

    @param {String} name The name of the composition to compose.
    @param {Function} compose The function to use to compose the `View`.
    ###

    _composeWithFunction: (name, compose) ->
      @_compose name, { compose }

    #### Compose With Function and Options ###
    ###
    Composes using the `compose` function in the context of the `Controller`.
    It __does not__ bind the function context, and is passed the `options` as
    a parameter. The `options` are further used to test if the `composition`
    should be re-composed.

    @param {String} name The name of the composition to compose.
    @param {Function} compose The function to use to compose the `composition`.
    @param {Object} options The options to be passed to the `composition`.
    ###

    _composeWithFunctionAndOptions: (name, compose, options) ->
      @_compose name, { options, compose }

    #### Compose With Options ###
    ###
    Calls the `compose` method of the `options` hash in place of a function.
    If present, the `check` method of the `options` hash is called to determine
    if re-composition is necessary.
    If not present, this method is functionally identical to
    `_composeWithFunctionAndOptions`.

    @see @_composeWithFunctionAndOptions

    @param {String} name The name of the composition to compose.
    @param {Object} options The options to be passed to the `composition`.
    ###

    _composeWithOptions: (name, options) ->
      @_compose name, options

    #### Compose ###
    ###
    Performs the actual composition after everything else gets "normalized".

    @param {String} name The name of the composition to compose.
    @param {Object} options The composition specification.

    @return {Promise?} May return a promise if the composition returns one.
    ###

    _compose: (name, options) ->
      # Ensure that we're not trying to compose a previous composed composition.
      throw new Error '''
        Composer#compose was used incorrectly
      ''' if typeof options.compose isnt 'function' and not options.composition?

      # Use the passed composition directly if we have it.
      if options.composition?
        composition = new options.composition options.options

      # Otherwise, create the composition and apply the methods (if available)
      else
        composition = @__factory().get 'Composition', options.options
        composition.compose = options.compose
        composition.check = options.check if options.check?

      # Check for an existing composition
      current = @compositions[name]

      # Apply the `check` method if available
      if current and current.check composition.options
        # Mark the current composition as not stale
        current.stale false

      # Otherwise, remove the current composition and apply the new one.
      else
        current.dispose() if current
        returned = composition.compose composition.options
        isPromise = returned and _.isFunction returned.then
        composition.stale false
        @compositions[name] = composition

      # Return the active composition
      return if isPromise then returned else @compositions[name].item

    ###
    Cleanup
    -------
    Any dispatched `Controller` action should be complete.
    Perform post-action disposal and delete all inactive compositions.
    Declare all active compositions as stale for the next dispatch cycle.

    @see application/composition.coffee
    @see mixins/disposable.coffee
    ###

    _cleanup: ->
      _.each @compositions, (composition, name) =>
        if composition.stale()
          composition.dispose()
          delete @compositions[name]
        else
          composition.stale true

    ###
    Dispose Compositions
    --------------------
    Invoke dispose on all of our compositions for memory-mamagement.

    @see mixins/disposable.coffee
    ###

    _disposeCompositions: ->
      _.invoke @compositions, 'dispose'

  ), mixins: [
    'PubSub.Mixin'
    'Listener.Mixin'
    'Disposable.Mixin'
    'CallbackProvider.Mixin'
  ]
