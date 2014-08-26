define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/pub-sub'
  'oraculum/mixins/evented'
  'oraculum/mixins/listener'
  'oraculum/mixins/disposable'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  ###
  Dispatcher
  ==========
  The job of the `Dispatcher` is receive and read the `Route` specifications
  from the `Router` and manage the lifecycle of the prescribed `Controller`.

  @see application/route.coffee
  @see application/router.coffee
  @see application/controller.coffee
  ###

  Oraculum.define 'Dispatcher', (class Dispatcher

    ###
    We cache the previous `Route` soec so that we can pass it through to a
    new `Route` for the purpose of allowing the `Controller` to perform logic
    against the old values. It contains the `Controller` action, path, and name.

    @type {Null|Object}
    ###

    previousRoute: null

    # The current controller, route information, and parameters.
    # The current route object contains the same information as previous.
    currentQuery: null
    currentRoute: null
    currentParams: null
    currentController: null

    ###
    Constructor
    -----------
    Allow custom initialization via the standard `initialize` method.
    ###

    constructor: ->
      @initialize? arguments...

    ###
    Mixin Options
    -------------
    Set up our event listeners.

    @see mixins/listener.coffee
    ###

    mixinOptions:
      listen:
        'router:match mediator': 'dispatch'

    ###
    Dispatch
    --------
    This method is the heart of the `Dispatcher`, providing the logic to create
    and dispose `Controllers`, and invoke their actions as prescribed by the
    current `Route` specification.

    The standard flow is:

      1. Test if it’s a new `Controller`/action with new params.
      1. Dispose the previous `Controller`.
      1. Instantiate the new `Controller`.
      1. Invoke the `Route` specification's prescribed action.

    @see application/route.coffee
    @see application/router.coffee
    @see application/controller.coffee

    @param {Object} route The current `Route` specification.
    @param {Object} params Any parameters defined in the `Route`'s specification.
    @param {Object} options The current `Route` options.
    ###

    dispatch: (route, params, options) ->
      # Clone params and options so the original objects remain untouched.
      params = _.extend {}, params
      options = _.extend {}, options

      # null or undefined query parameters are equivalent to an empty hash
      options.query ?= {}

      # Whether to force the controller startup even
      # if current and new controllers and params match
      # Default to false unless explicitly set to true.
      options.forceStartup = false unless options.forceStartup is true

      # Stop if the desired controller/action is already active
      # with the same params.
      return if not options.forceStartup and
        @currentRoute?.action is route.action and
        @currentRoute?.controller is route.controller and
        _.isEqual(@currentParams, params) and
        _.isEqual(@currentQuery, options.query)

      if @nextPreviousRoute = @currentRoute
        previous = _.extend {}, @nextPreviousRoute
        previous.params = @currentParams if @currentParams?
        delete previous.previous if previous.previous
        prev = {previous}

      @nextCurrentRoute = _.extend {}, route, prev

      controller = @__factory().get route.controller,
        params, @nextCurrentRoute, options

      @executeBeforeAction controller, @nextCurrentRoute, params, options

    ###
    Execute Before Action
    ---------------------
    Composes the options for and invokes the current `Controller`'s
    `beforeAction` method, if it is available, before invoking the current
    `Route` specification's prescribed action.
    Tests the return value of the `beforeAction` method to check for a promise
    interface. If a promise is returned, the execution of the current `Route`
    specification's prescribed action will be deferred until the resolution
    of the returned promise.

    @see application/route.coffee
    @see application/router.coffee
    @see application/controller.coffee

    @param {Controller} controller The current controller.
    @param {Object} route The current `Route` specification.
    @param {Object} params Any parameters defined in the `Route`'s specification.
    @param {Object} options The current `Route` options.
    ###

    executeBeforeAction: (controller, route, params, options) ->
      {beforeAction} = controller

      executeAction = =>
        if controller.redirected or
        @currentRoute and route is @currentRoute
          @nextPreviousRoute = @nextCurrentRoute = null
          controller.dispose()
          return
        @currentRoute = @nextCurrentRoute
        @previousRoute = @nextPreviousRoute
        @nextPreviousRoute = @nextCurrentRoute = null
        @executeAction controller, route, params, options

      return executeAction() unless beforeAction

      # Execute action in controller context.
      promise = controller.beforeAction params, route, options
      if promise and promise.then
      then promise.then executeAction
      else executeAction()

    ###
    Execute Action
    --------------
    Executes the current `Route` specification's prescribed action.

    @see application/route.coffee

    @param {Controller} controller The current controller.
    @param {Object} route The current `Route` specification.
    @param {Object} params Any parameters defined in the `Route`'s specification.
    @param {Object} options The current `Route` options.
    ###

    executeAction: (controller, route, params, options) ->
      # Dispose the previous controller.
      if @currentController
        # Notify the rest of the world beforehand.
        @publishEvent 'beforeControllerDispose', @currentController
        # Passing new parameters that the action method will receive.
        @currentController.dispose params, route, options

      # Save the new controller and its parameters.
      @currentQuery = options.query
      @currentParams = params
      @currentController = controller

      # Call the controller action with params and options.
      controller[route.action] params, route, options

      # Stop if the action triggered a redirect.
      return if controller.redirected

      # We're done! Spread the word!
      @publishEvent 'dispatcher:dispatch', @currentController,
        params, route, options

  ), mixins: [
    'PubSub.Mixin'
    'Evented.Mixin'
    'Listener.Mixin'
    'Disposable.Mixin'
  ]
