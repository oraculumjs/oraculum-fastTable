require [
  'oraculum'
  'oraculum/mixins/callback-provider'
  'oraculum/views/mixins/region-attach'
], (Oraculum) ->
  'use strict'

  provideCallback = Oraculum.mixins['CallbackProvider.Mixin'].provideCallback
  removeCallbacks = Oraculum.mixins['CallbackProvider.Mixin'].removeCallbacks

  describe 'RegionAttach.ViewMixin', ->
    Oraculum.extend 'View', 'RegionAttach.View', {
      mixinOptions:
        attach:
          region: 'region1'
    }, mixins: ['RegionAttach.ViewMixin']

    dependsMixins Oraculum, 'RegionAttach.ViewMixin',
      'Attach.ViewMixin'
      'EventedMethod.Mixin'
      'CallbackDelegate.Mixin'

    it 'should read region at construction', ->
      view = Oraculum.get 'RegionAttach.View'
      expect(view.mixinOptions.attach.region).toBe 'region1'
      view.__dispose()
      view = Oraculum.get 'RegionAttach.View', region: 'region2'
      expect(view.mixinOptions.attach.region).toBe 'region2'
      view.__dispose()

    it 'should execute the region:show callback with the region/instance', ->
      view = Oraculum.get 'RegionAttach.View'
      provideCallback 'region:show', (region, instance) ->
        expect(region).toBe 'region1'
        expect(instance).toBe view
      view.attach()
      removeCallbacks()
