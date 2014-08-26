define [
  'oraculum'
  'oraculum/libs'
  'oraculum/views/mixins/attach'
  'oraculum/mixins/evented-method'
  'oraculum/mixins/callback-provider'
], (Oraculum) ->
  'use strict'

  # This mixin simply enhances the behavior of the `Attach.ViewMixin`
  Oraculum.defineMixin 'RegionAttach.ViewMixin', {

    mixinOptions:
      attach:
        region: null
      eventedMethods:
        attach: {}

    mixconfig: ({attach}, {region} = {}) ->
      attach.region = region if region?

    mixinitialize: ->
      @on 'attach:before', @_attachRegion, this

    _attachRegion: ->
      return unless region = @mixinOptions.attach.region
      @executeCallback 'region:show', region, this

  }, mixins: [
    'Attach.ViewMixin'
    'EventedMethod.Mixin'
    'CallbackDelegate.Mixin'
  ]
