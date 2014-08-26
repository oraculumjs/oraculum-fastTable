define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/evented'
  'oraculum/mixins/listener'
], (Oraculum) ->

  _ = Oraculum.get 'underscore'

  ###
  Handlers
  --------
  All callbacks registered across all instances invoking `provideCallback`
  will be collected here in the closure.

  @type {Object}
  ###

  handlers = {}

  ###
  CallbackProvider.Mixin
  ======================
  This mixin replaces the `setHandler` method implicit to Chaplin's mediator
  with the `provideCallback` method. It's functionally the same, however
  it can be mixed on any object providing a more consistent interface
  while allowing for other conveniences such as providing `this` as the
  default callback scope.
  ###

  Oraculum.defineMixin 'CallbackProvider.Mixin',

    ###
    Mixin Options
    -------------
    Allow the callback configuration to be defined using a mapping of callback
    names and methods as described in the examples below.s

    @param {Object} Object containing the callback map.
    ###

    #### Example configuration ###
    # ```coffeescript
    # mixinOptions:
    #   provideCallbacks:
    #     someName: -> doSomething()
    #     anotherName: 'instanceMethodName'
    # ```

    ###
    Mixinitialize
    -------------
    Initialize the component.
    ###

    mixinitialize: ->
      # Iterate over and register the configured callbacks
      _.each @mixinOptions.provideCallbacks, (callback, name) =>
        callback = @[callback] if _.isString callback
        @provideCallback name, callback, this

      # To make the callback collection memory-safe, listen for the disposal of
      # the instance and remove any callbacks it may have registered.
      @on? 'dispose:after', (target) => @removeCallbacks this if target is this

    ###
    Provide Callback
    ----------------
    The **only** registration interface to our callback collector.
    This method will perform sanity checking for registered callbacks as well as
    sane defaults to ensure that nothing gets pushed to the handlers cache that
    doesn't make sense.

    @param {String} name The name of the callback.
    @param {Function} callback The callback implemenation.
    @param {Object} instance? The instance to which the callback shoudl be scoped. (defaults to `this`)
    ###

    provideCallback: (name, callback, instance = this) ->
      throw new TypeError '''
        CallbackProvider.Mixin::provideCallback requires name
      ''' unless _.isString name

      throw new TypeError '''
        CallbackProvider.Mixin::provideCallback requires callback
      ''' unless _.isFunction callback

      handlers[name] = {callback, instance}
      return # void 0

    ###
    Remove Callbacks
    ----------------
    Similar to `provideCallback`, this is the only interface for removing
    callbacks from the collector. It accepts an array of callback names,
    or an instance. Providing an instance will remove all registered callbacks
    scoped to that instance.

    @param {Array} input A list of named callbacks to remove.
    @param {Object} input An instance scope to remove the callbacks for.
    ###

    removeCallbacks: (input) ->
      if _.isArray input then delete handlers[name] for name in input
      else for name, handler of handlers when handler.instance is input
        delete handlers[name]
      return # void 0

  ###
  CallbackDelegate.Mixin
  ======================
  This mixin provides the `executeCallback` method. It's only purpose is to
  allow the invocation of arbitrary callbacks registered by
  `CallbackProvider.Mixin`.
  ###

  Oraculum.defineMixin 'CallbackDelegate.Mixin',

    ###
    Execute Callback
    ----------------
    This method takes a callback name and attempts to invoked the registered
    callback of that name, passing through whatever arguments are provided.
    If the named callback is not available, this method will throw.
    The error throwing behavior can be bypassed by using an object as the
    first argument with the structure `{name: 'name', silent: true}`

    @param {String} name The named callback to execute.
    @param {Object} name The afformentioned silent spec.
    @param {[Mixed]} args Any arguments to pass to the callback.

    @return {Mixed} The return value of the callback, if any.
    ###

    executeCallback: (name, args...) ->
      {name, silent} = name if _.isObject name

      handler = handlers[name]
      throw new Error """
        CallbackDelegate.Mixin: No callback defined for #{name}
      """ if not handler and not silent

      return handler.callback.apply handler.instance, args if handler
