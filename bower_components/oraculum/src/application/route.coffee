define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/pub-sub'
  'oraculum/mixins/freezable'
  'oraculum/application/controller'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  # Cached regex for capturing required parameters from a `fragment`.
  paramRegExp = /(?::|\*)(\w+)/g

  # Cached regex for capturing optional parameters from a `fragment`.
  optionalRegExp = /\((.*?)\)/g

  # Cached regex for escaping special url characters.
  escapeRegExp = /[\-{}\[\]+?.,\\\^$|#\s]/g

  ###
  Route
  =====
  The `Route` represents a mapping between a url `fragment` and a method of a
  `Controller`, colloquially referred to as its `action`.
  A route's `fragment` can carry information about a particular `resource` that
  that the `Controller`'s `action` represents, such as the id of a particular
  `Model`, or other metadata.

  @see application/router.coffee
  @see application/history.coffee
  @see application/controller.coffee
  @see application/dispatcher.coffee
  ###

  Oraculum.define 'Route', (class Route

    ### Static Methods ###

    #### Process Trailing Slash ###
    ###
    Add or remove trailing slash from path according to trailing option.

    @param {String} path The path to process.
    @param {Boolean} trailing Wether to add or strip the trailing slash.

    @return {String} The processed path.
    ###

    @processTrailingSlash = (path, trailing) ->
      switch trailing
        when true then path += '/' unless path[-1..] is '/'
        when false then path = path[...-1] if path[-1..] is '/'
      return path

    #### Stringify Key Value ###
    ###
    Encode a key/val pair into a querystring component.

    @param {String} key The key for the url parameter.
    @param {Mixed} value The value to encode for the url parameter.

    @return {String} The resulting querystring component.
    ###

    @stringifyKeyValue = (key, value) ->
      return '' unless value?
      return "&#{key}=#{encodeURIComponent value}"

    #### Stringify Query Params ###
    ###
    Returns a query string from a hash.

    @param {Object} queryParams The object to be serialized to a querystring.

    @return {String} The resulting querystring.
    ###

    @stringifyQueryParams = (queryParams) ->
      query = ''
      _.each queryParams, (value, key) ->
        encodedKey = encodeURIComponent key
        if _.isArray value then _.each value, (arrParam) ->
          query += Route.stringifyKeyValue encodedKey, arrParam
        else query += Route.stringifyKeyValue encodedKey, value
      return query and query.substring 1

    ####  Parse Query String ###
    ###
    Deserialize a querystring to an object.

    @param {String} queryString The querystring to deserialized.

    @return {Object} The resulting object.
    ###

    @parseQueryString = (queryString) ->
      params = {}
      return params unless queryString

      pairs = queryString.split '&'
      _.each pairs, (pair) ->
        return unless pair.length
        [field, value] = pair.split '='
        return unless field.length
        field = decodeURIComponent field
        value = decodeURIComponent value
        current = params[field]
        if current
          # Handle multiple params with same name:
          # Aggregate them in an array.
          if current.push
          # Add the existing array.
          then current.push value
          # Create a new array.
          else params[field] = [current, value]
        else params[field] = value

      return params

    ###
    Constructor
    -----------
    Create a route for a URL pattern and a controller action
    e.g. new Route '/users/:id', 'users', 'show', { some: 'options' }

    @param {String} pattern The `fragment` that represents this route.
    @param {String} controller The `Controller` name this route should use.
    @param {String} action The `Controller`'s targeted `action`.
    @param {Object} options? Any options to be cached.
    ###

    constructor: (@pattern, @controller, @action, options) ->
      # Disallow regexp routes.
      throw new Error '''
        Route: RegExps are not supported.
        Use strings with :names and `constraints` option of route
      ''' unless _.isString @pattern

      # Clone options.
      @options = _.extend {}, options

      # Store the name on the route if given
      @name = @options.name if @options.name?

      # Don’t allow ambiguity with controller#action.
      throw new Error '''
        Route: "#" cannot be used in name
      ''' if @name and @name.indexOf("#") isnt -1

      # Set default route name.
      @name ?= "#{@controller}##{@action}"

      # Initialize list of :params which the route will use.
      @allParams = []
      @requiredParams = []
      @optionalParams = []

      # Check if the action is a reserved name
      throw new Error '''
        Route: You should not use existing controller properties as actions
      ''' if @action of @__factory().getConstructor('Controller').prototype

      @createRegExp()

    ###
    Mixin Options
    -------------
    Automatically freeze this object after its construction.

    @see mixins/freezable.coffee
    ###

    mixinOptions:
      freeze: true

    ###
    Matches
    -------
    Tests if route params are equal to pathSpec.

    @param {String} pathSpec The `fragment` to test as a string.
    @param {Object} pathSpec The `fragment` to test as an object.

    @return {Boolean} Whether or not the provided `fragment` is a match for this `Route`.
    ###

    matches: (pathSpec) ->
      return pathSpec is @name if _.isString pathSpec
      propCount = 0
      for name in ['name', 'action', 'controller']
        propCount++
        property = pathSpec[name]
        return false if property and property isnt this[name]
      invalidParamsCount = propCount is 1 and name in ['action', 'controller']
      return not invalidParamsCount

    ###
    Reverse
    -------
    Generates `fragment` for this `Route` from params and optional querystring.

    @param {Object} params The params for this `Route`.
    @param {Object} query? An optional query hash.
    @param {String} query? An optional querystring.

    @return {String} The resulting `fragment`.
    ###

    reverse: (params, query) ->
      params = @normalizeParams params
      return false if params is false

      url = @pattern

      # From a params hash; we need to be able to return
      # the actual URL this route represents.
      # Iterate and replace params in pattern.
      _.each @requiredParams, (param) ->
        value = params[param]
        url = url.replace ///[:*]#{param}///g, value

      # Replace optional params.
      _.each @optionalParams, (param) ->
        return unless value = params[param]
        url = url.replace ///[:*]#{param}///g, value

      # Kill unfulfilled optional portions.
      raw = url.replace optionalRegExp, (match, portion) ->
        return unless portion.match /[:*]/g
        then portion
        else ''

      # Add or remove trailing slash according to the Route options.
      url = Route.processTrailingSlash raw, @options.trailing

      return url unless query

      # Stringify query params if needed.
      return if _.isObject query
        queryString = Route.stringifyQueryParams query
        url += if queryString then '?' + queryString else ''
      else
        url += (if query[0] is '?' then '' else '?') + query

    ###
    Normalize Params
    ----------------
    Validates incoming params and returns them in a unified form - hash.

    @param {Object} params The params to normalize.
    @param {Array} params The params to normalize.

    @return {Object} The normalized params.
    @return {Boolean} `false` if `params` doesn't pass `testParams`.
    ###

    normalizeParams: (params) ->
      if _.isArray params
        # Ensure we have enough parameters.
        return false if params.length < @requiredParams.length

        # Convert params from array into object.
        paramsHash = {}
        _.each @requiredParams, (paramName, paramIndex) ->
          paramsHash[paramName] = params[paramIndex]

        return false unless @testConstraints paramsHash

        params = paramsHash
      else
        # null or undefined params are equivalent to an empty hash
        params ?= {}
        return false unless @testParams params

      return params

    ###
    Test Params
    -----------
    Test if passed params hash matches current route.

    @param {Object} params The params to test.

    @return {Boolean} Whether `params` match this `Route`.
    ###

    testParams: (params) ->
      # Ensure that params contains all the parameters needed.
      for paramName in @requiredParams
        return false if params[paramName] is undefined

      return @testConstraints params

    ###
    Test Constraints
    ----------------
    Test if passed params hash matches current constraints.

    @param {Object} params The params to test.

    @return {Boolean} Whether `params` match our constraints.
    ###

    testConstraints: (params) ->
      # Apply the parameter constraints.
      constraints = @options.constraints
      if constraints
        for own name, constraint of constraints
          return false unless constraint.test params[name]

      return true

    ###
    Create RegExp
    -------------
    Creates the actual regular expression that Backbone.History#loadUrl
    uses to determine if the current url is a match.

    @return {RegExp} The generated regular expression.
    ###

    createRegExp: ->
      pattern = @pattern

      # Escape magic characters.
      pattern = pattern.replace escapeRegExp, '\\$&'

      # Keep accurate back-reference indices in allParams.
      # Eg. Matching the regex returns arrays like [a, undefined, c]
      #  and each item needs to be matched to the correct
      #  named parameter via its position in the array.
      @replaceParams pattern, (match, param) =>
        @allParams.push param

      # Process optional route portions.
      pattern = pattern.replace optionalRegExp, =>
        @parseOptionalPortion.apply this, arguments

      # Process remaining required params.
      pattern = @replaceParams pattern, (match, param) =>
        @requiredParams.push param
        return @paramCapturePattern match

      # Create the actual regular expression, match until the end of the URL,
      # trailing slash or the begin of query string.
      return @regExp = ///^#{pattern}(?=\/?(?=\?|$))///

    ###
    Parse Optional Portion
    ----------------------
    Extract optional parameters from a `fragment`, caching them in
    `optionalParams`.

    @param {String} match The optional matched portion of the `fragment`.
    @param {String} optionalPortion The extracted optional matched parameter.

    @return {String} The optional matched portion of the `fragment` wrapped in a non-capturing group.
    ###

    parseOptionalPortion: (match, optionalPortion) ->
      # Extract and replace params.
      portion = @replaceParams optionalPortion, (match, param) =>
        @optionalParams.push param
        # Replace the match (eg. :foo) with capturing groups.
        return @paramCapturePattern match

      # Replace the optional portion with a non-capturing and optional group.
      return "(?:#{portion})?"

    ###
    Replace Params
    --------------
    A convenience method for processing parameter portions of a `fragment`.

    @param {String} s, `fragment` to be processed.
    @param {Function} callback Method used to process the process any matched parameters.

    @return {String} The processed `fragment`.
    ###

    replaceParams: (s, callback) ->
      # Parse :foo and *bar, replacing via callback.
      return s.replace paramRegExp, callback

    ###
    Param Capture Pattern
    ---------------------
    Extract the param name from a parameter spec in a `fragment`

    @param {String} param The `fragment` to process.

    @return {String} The extracted parameter name.
    ###

    paramCapturePattern: (param) ->
      return if param.charAt(0) is ':'
      then '([^\/\\?]+)' # Regexp for :foo.
      else '(.*?)' # Regexp for *foo.

    ###
    Test
    ----
    Test if the route matches to a path (called by Backbone.History#loadUrl).

    @param {String} path The `fragment` to test.

    @return {Boolean} Whether the `fragment` matches this `Route`'s specification.
    ###

    test: (path) ->
      # Test the main RegExp.
      return false unless matched = @regExp.test path

      # Apply the parameter constraints.
      constraints = @options.constraints
      return @testConstraints @extractParams path if constraints

      return true

    ###
    Handler
    -------
    The handler called by Backbone.History when the route matches.
    It is also called by Router#route which might pass options.

    @see application/router.coffee

    @param {String} pathSpec The path spec for this `Route` as a url.
    @param {Object} pathSpec The path spec for this `Route` as an object.
    @param {Object} options? Any options tfor this `Route`.
    ###

    handler: (pathSpec, options) =>
      options = _.extend {}, options

      # pathDesc may be either an object with params for reversing
      # or a simple URL.
      if _.isObject pathSpec
        query = Route.stringifyQueryParams options.query
        params = pathSpec
        path = @reverse params
      else
        [path, query] = pathSpec.split '?'
        if not query?
        then query = ''
        else options.query = Route.parseQueryString query
        params = @extractParams path
        path = Route.processTrailingSlash path, @options.trailing

      actionParams = _.extend {}, params, @options.params

      # Construct a route object to forward to the match event.
      route = {path, @action, @controller, @name, query}

      # Publish a global event passing the route and the params.
      # Original options hash forwarded to allow further forwarding to backbone.
      @publishEvent 'router:match', route, actionParams, options

    ###
    Extract Params
    --------------
    Extract named parameters from a URL path.

    @param {String} path Path spec as a url.

    @return {Object} Path spec as an object.
    ###

    extractParams: (path) ->
      params = {}

      # Apply the regular expression.
      matches = @regExp.exec path

      # Fill the hash using param names and the matches.
      _.each matches.slice(1), (match, index) =>
        paramName = if @allParams.length
        then @allParams[index]
        else index
        params[paramName] = match

      return params

  ), mixins: [
    'PubSub.Mixin'
    'Freezable.Mixin'
  ]
