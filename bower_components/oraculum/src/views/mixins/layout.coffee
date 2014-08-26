define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/pub-sub'
  'oraculum/mixins/callback-provider'
  'oraculum/views/mixins/region-publisher'
  'oraculum/views/mixins/region-subscriber'
], (Oraculum) ->
  'use strict'

  $ = Oraculum.get 'jQuery'
  _ = Oraculum.get 'underscore'

  modifierKeyPressed = (event) ->
    return event.altKey or
    event.ctrlKey or
    event.metaKey or
    event.shiftKey or
    event.button is 1

  Oraculum.defineMixin 'Layout.ViewMixin', {

    mixinOptions:
      layout:
        title: ''
        scrollTo: [0,0]
        routeLinks: 'a, .go-to'
        skipRouting: '.noscript'
        openExternalToBlank: false
        titleTemplate: (data) ->
          return if data.subtitle
          then "#{data.subtitle} - #{data.title}"
          else data.title
      disposable:
        disposeAll: true

    mixconfig: ({layout}, options = {}) ->
      {title, scrollTo, routeLinks} = options
      layout.title = title if title?
      layout.scrollTo = scrollTo if scrollTo?
      layout.routeLinks = routeLinks if routeLinks?

      {skipRouting, titleTemplate, openExternalToBlank} = options
      layout.skipRouting = skipRouting if skipRouting?
      layout.titleTemplate = titleTemplate if titleTemplate?
      layout.openExternalToBlank = openExternalToBlank if openExternalToBlank?

    mixinitialize: ->
      @subscribeEvent '!scrollTo', @scrollTo
      @subscribeEvent '!adjustTitle', @adjustTitle
      @subscribeEvent 'beforeControllerDispose', @scroll
      @startLinkRouting() if @mixinOptions.layout.routeLinks
      @on 'dispose', @stopLinkRouting, this

    # Controller startup and disposal
    # -------------------------------
    # Handler for the global beforeControllerDispose event.
    scroll: ->
      # Reset the scroll position.
      return unless scrollTo = @mixinOptions.layout.scrollTo
      [x, y] = scrollTo
      window.scrollTo x, y

    scrollTo: (selector, args...) ->
      scroll = scrollTop: $(selector).offset().top
      $(document.body).animate scroll, args...

    # Handler for the global dispatcher:dispatch event.
    # Change the document title to match the new controller.
    # Get the title from the title property of the current controller.
    adjustTitle: (subtitle = '') ->
      title = @mixinOptions.layout.title
      titleTemplate = @mixinOptions.layout.titleTemplate
      document.title = titleTemplate { title, subtitle }
      return title

    # Automatic routing of internal links
    # -----------------------------------
    startLinkRouting: ->
      return unless routeLinks = @mixinOptions.layout.routeLinks
      @$el.on 'click', routeLinks, (event) => @openLink event

    stopLinkRouting: ->
      return unless {routeLinks} = @mixinOptions.layout
      @$el.off 'click', routeLinks

    isExternalLink: (link) ->
      return link.rel is 'external' or
        link.target is '_blank' or
        link.hostname not in [location.hostname, ''] or
        link.protocol not in ['http:', 'https:', 'file:']

    # Handle all clicks on A elements and try to route them internally.
    openLink: (event) ->
      return if modifierKeyPressed event
      el = event.currentTarget

      # Get the href and perform checks on it.
      href = el.getAttribute('href') or el.getAttribute('data-href') or null

      # Basic href checks.
      return if not href?

      # Technically an empty string is a valid relative URL
      # but it doesn’t make sense to route it.
      return if href is ''

      # Exclude fragment links.
      return if href.charAt(0) is '#'

      # Exclude javascript:void(0); (common no-op paradigm)
      return if /^javascript:\s*void\(.*\);?$/.test href

      {skipRouting, openExternalToBlank} = @mixinOptions.layout

      # Apply skipRouting option.
      type = typeof skipRouting
      return if _.isString(skipRouting) and $(el).is skipRouting
      return if _.isFunction(skipRouting) and not skipRouting href, el

      # Handle external links.
      isAnchor = el.nodeName is 'A'
      isExternalLink = isAnchor and @isExternalLink el
      if isExternalLink
        if openExternalToBlank
          # Open external links normally in a new tab.
          event.preventDefault()
          window.open href
        return # void 0

      # Pass to the router, try to route the path internally.
      @executeCallback 'router:route', url: href

      # Prevent default handling if the URL could be routed.
      event.preventDefault()
      return false

  }, mixins: [
    'PubSub.Mixin'
    'CallbackDelegate.Mixin'
    'RegionSubscriber.ViewMixin'
    'RegionPublisher.ViewMixin'
  ]
