define [
  'oraculum'
  'oraculum/libs'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'
  Backbone = Oraculum.get 'Backbone'

  # Cached regex for stripping a leading hash/slash and trailing space.
  routeStripper = /^[#\/]|\s+$/g

  # Cached regex for stripping leading and trailing slashes.
  rootStripper = /^\/+|\/+$/g

  # Cached regex for removing a trailing slash.
  trailingSlash = /\/$/

  ###
  History
  =======
  Patch Backbone.History with a basic query strings support.

  @see http://backbonejs.org/#History
  ###

  Oraculum.define 'History', class History extends Backbone.History

    ###
    Get Fragment Override
    ---------------------
    Get the cross-browser normalized URL fragment, either from the URL,
    the hash, or the override.

    @param {String} fragment The current URL fragment.
    @param {Boolean} forcePushState? Flag used to force a change to the URL via push state.
    ###

    getFragment: (fragment, forcePushState) ->
      unless fragment?
        if @_hasPushState or not @_wantsHashChange or forcePushState
          # CHANGED: Make fragment include query string.
          root = @root.replace trailingSlash, ''
          fragment = @location.pathname + @location.search
          fragment = fragment.substr root.length unless fragment.indexOf root
        else
          fragment = @getHash()

      return fragment.replace routeStripper, ''

    ###
    Start Override
    --------------
    Start the hash change handling, returning `true` if the current URL matches
    an existing route, and `false` otherwise.

    @param {Object} options
    ###

    start: (options) ->
      throw new Error '''
        Backbone.history has already been started
      ''' if Backbone.History.started is true
      Backbone.History.started = true

      # Figure out the initial configuration. Do we need an iframe?
      # Is pushState desired ... is it available?
      @options = _.extend {}, {root: '/'}, @options, options

      @root = @options.root
      @fragment = @getFragment()
      @_hasPushState = Boolean (@options.pushState and @history?.pushState)
      @_wantsPushState = Boolean @options.pushState
      @_wantsHashChange = @options.hashChange isnt false

      # Normalize root to always include a leading and trailing slash.
      @root = "/#{@root}/".replace rootStripper, '/'

      # Depending on whether we're using pushState or hashes, and whether
      # 'onhashchange' is supported, determine how we check the URL state.
      if (@_hasPushState)
      then Backbone.$(window).on 'popstate', @checkUrl

      else if @_wantsHashChange and 'onhashchange' of window
      then Backbone.$(window).on 'hashchange', @checkUrl

      else if @_wantsHashChange
      then @_checkUrlInterval = setInterval @checkUrl, @interval

      # Determine if we need to change the base url, for a pushState link
      # opened by a non-pushState browser.
      loc = @location
      atRoot = @location.pathname.replace(/[^\/]$/, '$&/') is @root

      # If we've started off with a route from a `pushState`-enabled browser,
      # but we're currently in a browser that doesn't support it...
      if @_wantsPushState and @_wantsHashChange
        if not atRoot and not @_hasPushState
          # CHANGED: Prevent query string from being added before hash.
          # So, it will appear only after #, as it has been already included
          # into @fragment
          @fragment = @getFragment null, true
          @location.replace "#{@root}##{@fragment}"
          # Return immediately as browser will do redirect to new url
          return true

        # Or if we've started out with a hash-based route, but we're currently
        # in a browser where it could be `pushState`-based instead...
        else if atRoot and loc.hash
          @fragment = @getHash().replace routeStripper, ''
          # CHANGED: It's no longer needed to add loc.search at the end,
          # as query params have been already included into @fragment
          @history.replaceState {}, document.title, "#{@root}#{@fragment}"

      @loadUrl() unless @options.silent

    ###
    Navigate Override
    -----------------
    Save a fragment into the hash history, or replace the URL state if the
    'replace' option is passed. You are responsible for properly URL-encoding
    the fragment in advance.

    The options object can contain `trigger: true` if you wish to have the
    route callback be fired (not usually desirable), or `replace: true`, if
    you wish to modify the current URL without adding an entry to the history.

    @param {String} fragment The url fragment to route.
    @param {Object} options? An object containing navigation options.
    @param {Boolean} options? An Boolean value indicating whether to trigger the route callback.
    ###

    navigate: (fragment = '', options = false) ->
      return false unless Backbone.History.started
      options = {trigger: options} if _.isBoolean options

      fragment = @getFragment fragment
      url = "#{@root}#{fragment}"

      # Remove fragment replace, coz query string different mean difference page
      # Strip the fragment of the query and hash for matching.
      # fragment = fragment.replace(pathStripper, '')
      return false if @fragment is fragment
      @fragment = fragment

      # Don't include a trailing slash on the root.
      url = url.slice 0, -1 if fragment.length is 0 and url isnt '/'

      # If pushState is available, we use it to set the fragment as a real URL.
      if @_hasPushState
        historyMethod = if options.replace then 'replaceState' else 'pushState'
        @history[historyMethod] {}, document.title, url

      # If hash changes haven't been explicitly disabled, update the hash
      # fragment to store history.
      else if @_wantsHashChange
        @_updateHash @location, fragment, options.replace
        # iframe
        isSameFragment = fragment isnt @getFragment @getHash @iframe
        if @iframe? and isSameFragment
          # Opening and closing the iframe tricks IE7 and earlier to push a
          # history entry on hash-tag change.  When replace is true, we don't
          @iframe.document.open().close() unless options.replace
          @_updateHash @iframe.location, fragment, options.replace

      # If you've told us that you explicitly don't want fallback hashchange-
      # based history, then `navigate` becomes a page refresh.
      else
        return @location.assign url

      if options.trigger
        return @loadUrl fragment
