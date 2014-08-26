# Unit tests ported from Chaplin
require [
  'oraculum'
  'oraculum/libs'
  'oraculum/application/controller'
  'oraculum/mixins/callback-provider'
], (Oraculum) ->
  'use strict'

  Backbone = Oraculum.get 'Backbone'
  provideCallback = Oraculum.mixins['CallbackProvider.Mixin'].provideCallback
  removeCallbacks = Oraculum.mixins['CallbackProvider.Mixin'].removeCallbacks

  describe 'Controller', ->
    Controller = Oraculum.getConstructor 'Controller'
    definition = Oraculum.definitions['Controller']
    ctor = definition.constructor

    controller = null

    containsMixins definition,
      'PubSub.Mixin'
      'Evented.Mixin'
      'Disposable.Mixin'
      'CallbackDelegate.Mixin'

    beforeEach ->
      controller = new Controller()
      removeCallbacks()

    afterEach ->
      controller.dispose()
      removeCallbacks()
      Backbone.off()

    it 'should mixin a Backbone.Events', ->
      expect(controller).toImplement Backbone.Events

    it 'should redirect to a URL', ->
      expect(controller.redirectTo).toBeFunction()

      routerRoute = sinon.spy()
      provideCallback 'router:route', routerRoute

      url = 'redirect-target/123'
      controller.redirectTo url

      expect(controller.redirected).toBeTrue()
      expect(routerRoute).toHaveBeenCalledOnce()
      expect(routerRoute).toHaveBeenCalledWith url

    it 'should redirect to a URL with routing options', ->
      routerRoute = sinon.spy()
      provideCallback 'router:route', routerRoute

      url = 'redirect-target/123'
      options = replace: true
      controller.redirectTo url, options

      expect(controller.redirected).toBeTrue()
      expect(routerRoute).toHaveBeenCalledOnce()
      expect(routerRoute).toHaveBeenCalledWith url, options

    it 'should redirect to a named route', ->
      routerRoute = sinon.spy()
      provideCallback 'router:route', routerRoute

      name = 'params'
      params = one: '21'
      pathDesc = name: name, params: params
      controller.redirectTo pathDesc

      expect(controller.redirected).toBeTrue()
      expect(routerRoute).toHaveBeenCalledOnce()
      expect(routerRoute).toHaveBeenCalledWith pathDesc

    it 'should redirect to a named route with options', ->
      routerRoute = sinon.spy()
      provideCallback 'router:route', routerRoute

      name = 'params'
      params = one: '21'
      pathDesc = name: name, params: params
      options = replace: true
      controller.redirectTo pathDesc, options

      expect(controller.redirected).toBeTrue()
      expect(routerRoute).toHaveBeenCalledOnce()
      expect(routerRoute).toHaveBeenCalledWith pathDesc, options

    it 'should adjust page title', ->
      spy = sinon.spy()
      Backbone.on '!adjustTitle', spy
      controller.adjustTitle 'meh'
      expect(spy).toHaveBeenCalledOnce()
      expect(spy).toHaveBeenCalledWith 'meh'
