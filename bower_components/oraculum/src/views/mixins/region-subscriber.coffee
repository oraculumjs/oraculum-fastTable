define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/callback-provider'
], (Oraculum) ->
  'use strict'

  $ = Oraculum.get 'jQuery'

  Oraculum.defineMixin 'RegionSubscriber.ViewMixin', {
    # Regions
    # -------
    # Collection of registered regions; all view regions are collected here.
    globalRegions: null

    mixinitialize: ->
      @globalRegions = []
      @provideCallback 'region:show', @showRegion
      @provideCallback 'region:find', @regionByName
      @provideCallback 'region:register', @registerRegionHandler
      @provideCallback 'region:unregister', @unregisterRegionHandler

    # Region management
    # -----------------
    # Handler for `!region:register`.
    # Register a single view region or all regions exposed.
    registerRegionHandler: (instance, name, selector) ->
      if name?
      then @registerGlobalRegion instance, name, selector
      else @registerGlobalRegions instance

    # Registering one region bound to a view.
    registerGlobalRegion: (instance, name, selector) ->
      # Remove the region if there was already one registered perhaps by
      # a base class.
      @unregisterGlobalRegion instance, name

      # Place this region registration into the regions array.
      @globalRegions.unshift {instance, name, selector}

    # Triggered by view; passed in the regions hash.
    # Simply register all regions exposed by it.
    registerGlobalRegions: (instance) ->
      # Regions can be be extended by subclasses, so we need to check the
      # whole prototype chain for matching regions. Regions registered by the
      # more-derived class overwrites the region registered by the less-derived
      # class.
      _.each instance.mixinOptions.regions, (selector, name) =>
        @registerGlobalRegion instance, name, selector
      return # Return nothing.

    # Handler for `region:unregister`.
    # Unregisters single named region or all view regions.
    unregisterRegionHandler: (instance, name) ->
      if name?
      then @unregisterGlobalRegion instance, name
      else @unregisterGlobalRegions instance

    # Unregisters a specific named region from a view.
    unregisterGlobalRegion: (instance, name) ->
      cid = instance.cid
      @globalRegions = (region for region in @globalRegions when (
        region.instance.cid isnt cid or region.name isnt name
      ))

    # When views are disposed; remove all their registered regions.
    unregisterGlobalRegions: (instance) ->
      @globalRegions = (region for region in @globalRegions when (
        region.instance.cid isnt instance.cid
      ))

    # Returns the region by its name, if found.
    regionByName: (name) -> _.find @globalRegions, (region) ->
      region.name is name and not region.instance.stale

    # When views are instantiated and request for a region assignment;
    # attempt to fulfill it.
    showRegion: (name, instance) ->
      # Find an appropriate region.
      region = @regionByName name

      # Assert that we got a valid region.
      throw new Error """
        No region registered under #{name}
      """ unless region

      # Apply the region selector.
      attach = instance.mixinOptions.attach
      attach.container = if region.selector is ''
      then region.instance.$el
      else if region.instance.noWrap
      then $(region.instance.container).find region.selector
      else region.instance.$ region.selector

  }, mixins: [
    'CallbackProvider.Mixin'
  ]
