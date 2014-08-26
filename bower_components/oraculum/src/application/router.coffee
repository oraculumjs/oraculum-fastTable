define [
  'oraculum'
  'oraculum/libs'

  'oraculum/application/route'
  'oraculum/application/history'

  'oraculum/mixins/pub-sub'
  'oraculum/mixins/evented'
  'oraculum/mixins/listener'
  'oraculum/mixins/disposable'
  'oraculum/mixins/callback-provider'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  # Escapes a string to use in a regex.
  escapeRegExp = (str) ->
    return String(str or '').replace /([.*+?^=!:${}()|[\]\/\\])/g, '\\$1'

  ###
  Router
  ======
  The router which is a replacement for `Backbone.Router`.
  Like the standard router, it creates a `Backbone.History` instance and
  registers routes on it.
  It does not extend `Backbone.Router`, it instead replaces it.

  @see application/route.coffee
  @see application/history.coffee
  @see application/controller.coffee
  @see application/dispatcher.coffee
  @see http://backbonejs.org/#Router
  @see http://backbonejs.org/#History
  ###

  Oraculum.define 'Router', (class Router

    ###
    Constructor
    -----------

    @param {Object} options? Any options to be cached or passed to our initializers.
    ###

    constructor: (options = {}) ->
      # Enable pushState by default for HTTP(s).
      # Disable it for file:// schema.
      isWeb = window.location.protocol in ['http:', 'https:']
      @options = _.extend {
        root: '/'
        trailing: false
        pushState: isWeb
      }, options

      # Cached regex for stripping a leading subdir and hash/slash.
      rootRegex = escapeRegExp @options.root
      @removeRoot = new RegExp "^#{rootRegex}(#)?"

      @createHistory()

    ###
    Mixin Options
    -------------
    Set up our event listeners and named callbacks.

    @see mixins/listener.coffee
    @see mixins/callback-provider.coffee
    ###

    mixinOptions:
      listen:
        'dispose this': '_deleteHistory'
        'dispatcher:dispatch mediator': 'changeURL'
      provideCallbacks:
        'router:route': 'route'
        'router:reverse': 'reverse'

    ###
    Create History
    --------------
    Create a Backbone.History instance.
    ###

    createHistory: ->
      Backbone.history = @__factory().get 'History'

    ###
    Start History
    -------------
    Start the Backbone.History instance to start routing.
    This should be called after all routes have been registered.
    ###

    startHistory: ->
      Backbone.history.start @options

    ###
    Stop History
    ------------
    Stop the current Backbone.History instance from observing URL changes.
    ###

    stopHistory: ->
      return unless Backbone.History.started
      Backbone.history.stop()

    ###
    Find Handler
    ------------
    Search through backbone history handlers.

    @param {Function} predicate Matching function used to identify the desired handler.

    @return {Function} The desired handler or `undefined`.
    ###

    findHandler: (predicate) ->
      return _.find Backbone.history.handlers, (handler) ->
        return predicate handler

    ###
    Match
    -----
    Connect an address with a controller action.
    Creates a route on the Backbone.History instance.

    @param {String} pattern A `Route` path spec.
    @param {String} target A `Route` spec as a string.
    @param {Object} target A `Route` spec as an object.
    @param {Object} options? Any options to pass to the `Route`.
    ###

    match: (pattern, target, options = {}) =>
      return if _.isString target
      then @matchWithPatternAndString pattern, target, options
      else @matchWithPatternAndOptions pattern, target

    #### Match With Pattern and String ###
    ###
    Match a `Route` path spec with a `Route` spec as a string.

    @param {String} pattern A `Route` path spec.
    @param {Object} target A `Route` spec as an object.
    @param {Object} options? Any options to pass to the `Route`.
    ###

    matchWithPatternAndString: (pattern, string, options) ->
      {controller, action} = options
      throw new Error '''
        Router#matchWithPatternAndString cannot use both string
        and controller/action
      ''' if controller and action
      [controller, action] = string.split '#'
      @addHandler pattern, controller, action, options

    #### Match With Pattern and Options ###
    ###
    Match a `Route` path spec with a `Route` spec as an object.

    @param {String} pattern A `Route` path spec.
    @param {Object} target A `Route` spec as an object.
    ###

    matchWithPatternAndOptions: (pattern, options) ->
      {controller, action} = options
      throw new Error '''
        Router#matchWithPatternAndOptions must receive controller and action
      ''' unless controller and action
      @addHandler pattern, controller, action, options

    ###
    Add Handler
    -----------
    Create a `Route` object and add it to the `History`'s handlers.

    @param {String} pattern A `Route` path spec.
    @param {String} controller A `Controller` name.
    @param {String} action The `Controller`'s targeted `action`
    @param {Object} options? Any options to pass to the `Route`.
    ###

    addHandler: (pattern, controller, action, options) ->
      # Let each match provide its own trailing option to appropriate Route.
      # Pass trailing value from the Router by default.
      _.defaults options, trailing: @options.trailing
      # Create the route.
      route = @__factory().get 'Route', arguments...
      # Register the route at the Backbone.History instance.
      # Don’t use Backbone.history.route here because it calls
      # handlers.unshift, inserting the handler at the top of the list.
      # Since we want routes to match in the order they were specified,
      # we’re appending the route at the end.
      Backbone.history.handlers.push {route, callback: route.handler}
      return route

    ###
    Route
    -----
    Route a given URL path manually.
    This looks quite like Backbone.History::loadUrl but it accepts an absolute
    URL with a leading slash (e.g. /foo) and passes the routing options to the
    callback function.

    @param {String} pathSpec The spec for the target `Route` as a string.
    @param {Object} pathSpec The spec for the target `Route` as an object.
    @param {Object} params Any params to pass to the `Route`.
    @param {Object} options? Any options to pass to the handler.

    @return {Boolean} Whether a route matched.
    ###

    route: (pathSpec, params, options) ->
      # Try to extract an URL from the pathSpec if it's a hash.
      if _.isObject pathSpec
        path = pathSpec.url
        params ?= pathSpec.params

      params = if _.isArray params
      then params.slice()
      else _.extend {}, params

      return if path?
      then @routeWithPath path, params
      else @routeWithPathSpec pathSpec, params, options

    #### Route With Path ###
    ###
    Find and execute a `Route` handler by path.

    @param {String} path The path to use to lookup the `Route` handler.
    @param {Object} options? Any options to pass to the handler.

    @return {Boolean} Whether a route matched.
    ###

    routeWithPath: (path, options) ->
      # Remove leading subdir and hash or slash.
      path = path.replace @removeRoot, ''
      # Find a matching route.
      handler = @findHandler (handler) -> handler.route.test path
      return @handleRoute handler, path, options

    #### Route With Path Spec ###
    ###
    Find and execute a `Route` handler by path spec.

    @param {String} path The path spec to use to lookup the `Route` handler.
    @param {Object} params The `Route`'s params.
    @param {Object} options? Any options to pass to the handler.

    @return {Boolean} Whether a route matched.
    ###

    routeWithPathSpec: (pathSpec, params, options = {}) ->
      handler = @findHandler (handler) ->
        matches = handler.route.matches pathSpec
        normalizedParams = handler.route.normalizeParams params
        return Boolean (matches and normalizedParams)
      return @handleRoute handler, params, options

    #### Handle Route ###
    ###
    Invoke a matched `Route`'s handler callback.

    @param {Function} handler The matched handler callback.
    @param {Object} params The `Route`'s params.
    @param {Object} options? Any options to pass to the handler.

    @return {Boolean} `true`.
    ###

    handleRoute: (handler, params, options) ->
      throw new Error '''
        Router#route: request was not routed
      ''' unless handler
      handler.callback params, _.extend {changeURL: true}, options
      return true

    ###
    Reverse
    -------
    Find the URL for given pathSpec using the registered routes and provided
    parameters. The pathSpec may be just the name of a route or an object
    containing the name, controller, and/or action.

    Warning: this is usually **hot** code in terms of performance.

    @param {String} pathSpec The spec for the target `Route` as a string.
    @param {Object} pathSpec The spec for the target `Route` as an object.
    @param {Object} params The `Route`'s params.
    @param {Object} query? An optional query hash.
    @param {String} query? An optional querystring.

    @return {String} The URL string if it is found.
    @return {Boolean} `false` if the string is not found.
    ###

    reverse: (pathSpec, params, query) ->
      root = @options.root

      throw new TypeError '''
        Router#reverse: params must be an array or an object
      ''' if params? and not (_.isObject(params) or _.isArray(params))

      # First filter the route handlers to those that are of the same name.
      {handlers} = Backbone.history
      for handler in handlers when handler.route.matches pathSpec
        # Attempt to reverse using the provided parameter hash.
        reversed = handler.route.reverse params, query
        # Return the url if we got a valid one; else we continue on.
        if reversed isnt false
          return if root
          then "#{root}#{reversed}"
          else reversed

      # We didn't get anything.
      throw new Error '''
        Router#reverse: invalid route specified
      '''

    ###
    Change URL
    ----------
    Change the current URL, add a history entry. Invoked upon dispatch.

    @param {Controller} controller The current `Controller`.
    @param {Object} params The `Route`'s params.
    @param {Object} route The current `Route` spec.
    @param {Object} options? Any options present when dispatch occured.
    ###

    changeURL: (controller, params, route, options) ->
      {path, query} = route
      {changeURL, trigger, replace} = options
      return unless path? and changeURL

      url = path
      url += if query then "?#{query}" else ''

      # Do not trigger or replace per default.
      navigateOptions =
        trigger: trigger is true
        replace: replace is true

      # Navigate to the passed URL and forward options to Backbone.
      Backbone.history.navigate url, navigateOptions

    ###
    Delete History
    --------------
    Invoked upon disposal of this `Router`.
    ###

    _deleteHistory: ->
      @stopHistory()
      delete Backbone.history

  ), {
    override: true
    mixins: [
      'PubSub.Mixin'
      'Evented.Mixin'
      'Listener.Mixin'
      'Disposable.Mixin'
      'CallbackProvider.Mixin'
    ]
  }
