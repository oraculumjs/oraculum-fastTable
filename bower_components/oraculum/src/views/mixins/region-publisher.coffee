define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/callback-provider'
], (Oraculum) ->
  'use strict'

  Oraculum.defineMixin 'RegionPublisher.ViewMixin', {

    # Example regions configuration
    # -----------------------------
    # ```coffeescript
    # mixinOptions:
    #   regions:
    #     body: 'body'
    #     content: '#content'
    # ```

    mixconfig: (mixinOptions, {regions} = {}) ->
      mixinOptions.regions = _.extend {}, mixinOptions.regions, regions

    mixinitialize: ->
      {regions} = @mixinOptions
      @executeCallback 'region:register', this if regions?
      @on 'dispose', @unregisterAllRegions, this

    # Functionally register a single region.
    registerRegion: (name, selector) ->
      @executeCallback 'region:register', this, name, selector

    # Functionally unregister a single region by name.
    unregisterRegion: (name) ->
      @executeCallback 'region:unregister', this, name

    # Unregister all regions; called upon view disposal.
    unregisterAllRegions: ->
      @executeCallback 'region:unregister', this

  }, mixins: [
    'CallbackDelegate.Mixin'
  ]
