# Unit tests ported from Chaplin
require [
  'oraculum'
  'oraculum/libs'
  'oraculum/application/composer'
  'oraculum/application/controller'
  'oraculum/application/dispatcher'
], (Oraculum) ->
  'use strict'

  $ = Oraculum.get 'jQuery'
  _ = Oraculum.get 'underscore'
  Backbone = Oraculum.get 'Backbone'
  provideCallback = Oraculum.mixins['CallbackProvider.Mixin'].provideCallback
  removeCallbacks = Oraculum.mixins['CallbackProvider.Mixin'].removeCallbacks

  describe 'Dispatcher', ->
    Dispatcher = Oraculum.getConstructor 'Dispatcher'
    definition = Oraculum.definitions['Dispatcher']
    ctor = definition.constructor

    # Initialize shared variables
    dispatcher = composer = null
    params = path = options = stdOptions = null
    route1 = route2 = redirectToURLRoute = redirectToControllerRoute = null

    # Default options which are added on first dispatching
    addedOptions =
      forceStartup: false

    # Test controllers
    Test1Controller = Oraculum.extend('Controller', 'Test1Controller', {
      redirectToURL: -> @redirectTo '/test/123'
      dispose: -> @disposed = true
      show: -> '\x90'
    }, mixins: [
      'PubSub.Mixin'
      'Evented.Mixin'
      'CallbackDelegate.Mixin'
    ]).getConstructor 'Test1Controller'

    Test2Controller = Oraculum.extend('Controller', 'Test2Controller', {
      show: (params, options) -> '\x90'
      dispose: -> @disposed = true
    }, mixins: [
      'PubSub.Mixin'
      'Evented.Mixin'
      'CallbackDelegate.Mixin'
    ]).getConstructor 'Test2Controller'

    # Shortcut for publishing router:match events
    publishMatch = ->
      Backbone.trigger 'router:match', arguments...

    # Helper for creating params/options to compare with
    create = -> _.extend {}, arguments...

    # Reset helper: Create fresh params and options
    refreshParams = ->
      params = id: _.uniqueId('paramsId')
      path = "test/#{params.id}"
      options = {}
      stdOptions = create addedOptions, query: {}

      # Fake route objects, walk like a route and swim like a route
      route1 = {controller: 'Test1Controller', action: 'show', path}
      route2 = {controller: 'Test2Controller', action: 'show', path}
      redirectToURLRoute = {controller: 'Test1Controller', action: 'redirectToURL', path}
      redirectToControllerRoute = {controller: 'Test1Controller', action: 'redirectToController', path}

    beforeEach ->
      # Create a fresh Dispatcher instance for each test
      dispatcher = new Dispatcher()
      refreshParams()

    afterEach ->
      dispatcher?.dispose()
      dispatcher = null

    containsMixins definition,
      'PubSub.Mixin'
      'Listener.Mixin'
      'Disposable.Mixin'

    # The Tests

    it 'should dispatch routes to controller actions', ->
      proto = Test1Controller.prototype
      initialize = sinon.spy proto, 'initialize'
      action     = sinon.spy proto, 'show'

      publishMatch route1, params, options

      # loadTest1Controller ->
      for spy in [initialize, action]
        expect(spy).toHaveBeenCalledOnce()
        expect(spy.firstCall.thisValue).toBeInstanceOf Test1Controller
        [passedParams, passedRoute, passedOptions] = spy.firstCall.args
        expect(passedParams).toEqual params
        expect(passedRoute).toEqual route1
        expect(passedOptions).toEqual stdOptions

      initialize.restore()
      action.restore()

    it 'should not start the same controller if params match', ->
      publishMatch route1, params, options

      proto = Test1Controller.prototype
      initialize = sinon.spy proto, 'initialize'
      action     = sinon.spy proto, 'show'

      publishMatch route1, params, create(options, query: {})

      expect(initialize).not.toHaveBeenCalled()
      expect(action).not.toHaveBeenCalled()

      initialize.restore()
      action.restore()

    it 'should start the same controller if params differ', ->
      proto = Test1Controller.prototype
      initialize = sinon.spy proto, 'initialize'
      action     = sinon.spy proto, 'show'

      paramsStore = []
      optionsStore = []

      for i in [0..1]
        refreshParams()
        paramsStore.push params
        optionsStore.push options
        publishMatch route1, params, options

      expect(initialize).toHaveBeenCalledTwice()
      expect(action).toHaveBeenCalledTwice()

      for i in [0..1]
        for spy in [initialize, action]
          [passedParams, passedRoute, passedOptions] = spy.args[i]
          expect(passedParams).toEqual paramsStore[i]
          expect(passedRoute.controller).toEqual route1.controller
          expect(passedRoute.action).toEqual route1.action
          if i is 1
            expect(passedRoute.previous.controller).toEqual route1.controller
          expect(passedOptions).toEqual stdOptions

      initialize.restore()
      action.restore()

    it 'should start the same controller if query parameters differ', ->
      proto = Test1Controller.prototype
      initialize = sinon.spy proto, 'initialize'
      action     = sinon.spy proto, 'show'

      optionsStore = []

      optionsStore.push query: key: 'a'
      optionsStore.push query: key: 'b'

      publishMatch route1, params, optionsStore[0]
      publishMatch route1, params, optionsStore[1]

      expect(initialize).toHaveBeenCalledTwice()
      expect(action).toHaveBeenCalledTwice()

      for i in [0..1]
        for spy in [initialize, action]
          [passedParams, passedRoute, passedOptions] = spy.args[i]
          expect(passedParams).toEqual params
          expect(passedRoute.controller).toEqual route1.controller
          expect(passedRoute.action).toEqual route1.action
          if i is 1
            expect(passedRoute.previous.controller).toEqual route1.controller
          expect(passedOptions).toEqual create(stdOptions, optionsStore[i])

      initialize.restore()
      action.restore()

    it 'should start the same controller if forced', ->
      proto = Test1Controller.prototype
      initialize = sinon.spy proto, 'initialize'
      action     = sinon.spy proto, 'show'

      paramsStore = []
      optionsStore = []

      for i in [0..1]
        refreshParams()
        paramsStore.push params
        optionsStore.push options
        options.forceStartup = true if i is 1
        publishMatch route1, params, options

      for i in [0..1]
        for spy in [initialize, action]
          [passedParams, passedRoute, passedOptions] = spy.args[i]
          expect(passedParams).toEqual paramsStore[i]
          expect(passedRoute.controller).toBe route1.controller
          expect(passedRoute.action).toBe route1.action
          expectedOptions = create stdOptions, optionsStore[i], {
            forceStartup: (if i is 0 then false else true)
          }
          expect(passedOptions).toEqual expectedOptions

        initialize.restore()
        action.restore()

    it 'should save the controller, action, params, query and path', ->
      publishMatch route1, params, options

      options1 = create(options, query: key: 'a')
      publishMatch route2, params, options1

      # Check that previous route is saved
      expect(dispatcher.previousRoute.controller).toBe 'Test1Controller'
      expect(dispatcher.currentController).toBeInstanceOf Test2Controller
      expect(dispatcher.currentRoute).toEqual create(route2, previous: create(route1, {params}))
      expect(dispatcher.currentParams).toEqual params
      expect(dispatcher.currentQuery).toEqual options1.query

    it 'should add the previous controller name to the route', ->
      action = sinon.spy Test2Controller.prototype, 'show'

      publishMatch route1, params, options
      publishMatch route2, params, options

      expect(action).toHaveBeenCalledOnce()
      route = action.firstCall.args[1]
      expect(route.controller).toBe route2.controller
      expect(route.action).toBe route2.action
      expect(route.previous).toBeObject()
      expect(route.previous.controller).toBe route1.controller
      expect(route.previous.action).toBe route1.action

      action.restore()

    it 'should dispose inactive controllers', ->
      dispose = sinon.spy Test1Controller.prototype, 'dispose'
      publishMatch route1, params, options
      publishMatch route2, params, options

      # It should pass the params and the new controller name
      expect(dispose).toHaveBeenCalledOnce()
      [passedParams, passedRoute] = dispose.firstCall.args
      expect(passedParams).toEqual params
      expect(passedRoute.controller).toEqual route2.controller
      expect(passedRoute.action).toEqual route2.action
      expect(passedRoute.path).toEqual route2.path

      dispose.restore()

    it 'should fire beforeControllerDispose events', ->
      publishMatch route1, params, options

      beforeControllerDispose = sinon.spy()
      Backbone.on 'beforeControllerDispose', beforeControllerDispose

      # Now route to Test2Controller
      publishMatch route2, params, options

      expect(beforeControllerDispose).toHaveBeenCalledOnce()

      # Event payload should be the now disposed controller
      passedController = beforeControllerDispose.firstCall.args[0]
      expect(passedController).toBeInstanceOf Test1Controller
      expect(passedController.disposed).toBeTrue()

      Backbone.off 'beforeControllerDispose', beforeControllerDispose

    it 'should publish dispatch events', ->
      dispatch = sinon.spy()
      Backbone.on 'dispatcher:dispatch', dispatch

      publishMatch route1, params, options
      publishMatch route2, params, options

      expect(dispatch).toHaveBeenCalledTwice()

      for i in [0..1]
        firstCall = i is 0
        args = dispatch.getCall(i).args
        expect(args.length).toBe 4
        [passedController, passedParams, passedRoute, passedOptions] = args
        expect(passedController).toBeInstanceOf(
          if firstCall then Test1Controller else Test2Controller
        )
        expect(passedParams).toEqual params
        expect(passedRoute.controller).toBe(
          if firstCall then 'Test1Controller' else 'Test2Controller'
        )
        expect(passedRoute.action).toBe 'show'
        if firstCall
          expect(passedRoute.previous).toBeUndefined()
        else
          expect(passedRoute.previous.controller).toBe('Test1Controller')
        expect(passedOptions).toEqual stdOptions

      Backbone.off 'dispatcher:dispatch', dispatch

    it 'should support redirection to an URL', ->
      dispatch = sinon.spy()
      Backbone.on 'dispatcher:dispatch', dispatch

      removeCallbacks()
      route = sinon.spy()
      provideCallback 'router:route', route

      # Dispatch a route to check if previous controller info is correct after
      # redirection
      publishMatch route1, params, options

      # Open another route that redirects somewhere
      refreshParams()
      actionName = 'redirectToURL'
      action = sinon.spy Test1Controller.prototype, actionName
      publishMatch redirectToURLRoute, params, options

      expect(action).toHaveBeenCalledOnce()
      [passedParams, passedRoute, passedOptions] = action.firstCall.args
      expect(passedParams).toEqual params
      expect(passedRoute.previous.controller).toEqual 'Test1Controller'
      expect(passedOptions).toEqual stdOptions

      # Don’t expect that the new controller was called
      # because we’re not testing the router. Just test
      # if execution stopped (e.g. Test1Controller is still active)
      expect(dispatcher.previousRoute.controller).toBe 'Test1Controller'
      expect(dispatcher.currentRoute.controller).toBe 'Test1Controller'
      expect(dispatcher.currentController).toBeInstanceOf Test1Controller
      expect(dispatcher.currentRoute.action).toBe actionName
      expect(dispatcher.currentRoute.path).toBe redirectToURLRoute.path

      expect(dispatch).toHaveBeenCalledOnce()
      expect(route).toHaveBeenCalledOnce()

      Backbone.off 'dispatcher:dispatch', dispatch
      action.restore()

    it 'should dispose when redirecting to a URL from controller action', ->
      Oraculum.extend 'Controller', 'RedirectingController', {
        show: -> dispatcher.dispatch route1, null, {changeURL: true}
        dispose: -> @disposed = true
      }, mixins: [
        'PubSub.Mixin'
        'Evented.Mixin'
        'CallbackDelegate.Mixin'
      ]

      RedirectingController = Oraculum.getConstructor 'RedirectingController'
      dispose = sinon.spy RedirectingController.prototype, 'dispose'

      route = {controller: 'RedirectingController', action: 'show', path}
      publishMatch route, params, options
      expect(dispose).toHaveBeenCalledOnce()
      dispose.restore()

    describe 'Before actions', ->

      NoBeforeController = Oraculum.extend('Controller', 'NoBeforeController', {
        beforeAction: null
        show: sinon.stub()
      }, inheritMixins: true).getConstructor 'NoBeforeController'

      BeforeActionController = Oraculum.extend('Controller', 'BeforeActionController', {
        beforeAction: ->
        show: ->
      }, inheritMixins: true).getConstructor 'BeforeActionController'

      beforeActionRoute = {controller: 'BeforeActionController', action: 'show', path}

      it 'should run the before action', ->
        proto = BeforeActionController.prototype
        beforeAction = sinon.spy proto, 'beforeAction'
        action = sinon.spy proto, 'show'
        publishMatch beforeActionRoute, params, options

        expect(beforeAction).toHaveBeenCalledOnce()
        expect(beforeAction.firstCall.thisValue).toBeInstanceOf BeforeActionController
        expect(action).toHaveBeenCalledOnce()
        expect(beforeAction.calledBefore(action)).toBeTrue()

        beforeAction.restore()
        action.restore()

      it 'should proceed if there is no before action', ->
        route = {controller: 'NoBeforeController', action: 'show', path}
        publishMatch route, params, options
        expect(NoBeforeController::show).toHaveBeenCalledOnce()

      it 'should throw an error if a before action method isn’t a function', ->
        BrokenController = Oraculum.extend('Controller', 'BrokenController', {
          beforeAction: {}
          show: ->
        }, inheritMixins: true).getConstructor 'BrokenController'
        route = {controller: 'BrokenController', action: 'show', path}
        failFunction = ->
          # Assume implementation detail (`controllerLoaded` method)
          # to bypass the asynchronous require(). An alternative would be
          # to mock require() so it’s synchronous.
          dispatcher.dispatch route, params, options
        expect(failFunction).toThrow()

      it 'should run the before action with the same arguments', ->
        action = sinon.spy()

        BeforeActionChainController = Oraculum.extend('Controller', 'BeforeActionChainController', {
          beforeAction: (params, route, options) ->
            params.newParam = 'foo'
            options.newOption = 'bar'
          show: action
        }, inheritMixins: true).getConstructor 'BeforeActionChainController'

        route = {controller: 'BeforeActionChainController', action: 'show', path}
        publishMatch route, params, options

        expect(action).toHaveBeenCalledOnce()
        [passedParams, passedRoute, passedOptions] = action.firstCall.args
        expect(passedParams).toEqual create(params, newParam: 'foo')
        expect(passedRoute).toEqual create(route)
        expect(passedOptions).toEqual create(stdOptions, newOption: 'bar')

    describe 'Asynchronous Before Actions', ->

      it 'should handle asynchronous before actions', ->
        dfd = new $.Deferred()
        promise = dfd.promise()

        AsyncBeforeActionController = Oraculum.extend('Controller', 'AsyncBeforeActionController', {
          beforeAction: -> promise
          show: ->
        }, {
          override: true
          inheritMixins: true
        }).getConstructor 'AsyncBeforeActionController'

        action = sinon.spy AsyncBeforeActionController.prototype, 'show'

        route = {controller: 'AsyncBeforeActionController', action: 'show', path}
        publishMatch route, params, options

        expect(action).not.toHaveBeenCalled()
        dfd.resolve()

        waitsFor -> action.callCount
        expect(action).toHaveBeenCalledOnce()
        action.restore()

      it 'should support multiple asynchronous controllers', ->
        AsyncBeforeActionController = Oraculum.extend('Controller', 'AsyncBeforeActionController', {
          beforeAction: ->
            # Return an already resolved Promise
            { then : (callback) -> callback() }
          show: ->
        }, {
          override: true
          inheritMixins: true
        }).getConstructor 'AsyncBeforeActionController'

        route = {controller: 'AsyncBeforeActionController', action: 'show', path}
        options.forceStartup = true

        proto = AsyncBeforeActionController.prototype
        i = 0
        times = 4

        test = ->
          beforeAction = sinon.spy proto, 'beforeAction'
          action = sinon.spy proto, 'show'
          publishMatch route, params, options

          expect(beforeAction).toHaveBeenCalledOnce()
          expect(action).toHaveBeenCalledOnce()

          beforeAction.restore()
          action.restore()

          test() if ++i < times

        test()

      it 'should kick around promises from compositions', (done) ->
        composer = Oraculum.get 'Composer'
        dfd = new $.Deferred()
        promise = dfd.promise()

        AsyncBeforeActionController = Oraculum.extend('Controller', 'AsyncBeforeActionController', {
          beforeAction: -> @reuse 'a', -> promise
          show: ->
        }, {
          override: true
          inheritMixins: true
        }).getConstructor 'AsyncBeforeActionController'

        route = {controller: 'AsyncBeforeActionController', action: 'show', path}
        options.forceStartup = true

        proto = AsyncBeforeActionController.prototype

        do ->
          beforeAction = sinon.spy proto, 'beforeAction'
          action = sinon.spy proto, 'show'
          publishMatch route, params, options

          expect(beforeAction).toHaveBeenCalledOnce()
          expect(action).not.toHaveBeenCalled()

          dfd.resolve()
          waitsFor -> action.callCount
          expect(action).toHaveBeenCalledOnce()

          beforeAction.restore()
          action.restore()

          composer.dispose()

      it 'should stop dispatching when another controller is started', ->
        dfd = new $.Deferred()
        promise = dfd.promise()

        NeverendingController = Oraculum.extend('Controller', 'NeverendingController', {
          beforeAction: -> promise
          show: ->
        }, {
          override: true
          inheritMixins: true
        }).getConstructor 'NeverendingController'

        firstRoute = {controller: 'NeverendingController', action: 'show', path}
        secondRoute = route2

        # Spies
        proto = NeverendingController.prototype
        beforeAction = sinon.spy proto, 'beforeAction'
        firstAction = sinon.spy proto, 'show'
        secondAction = sinon.spy Test2Controller.prototype, 'show'

        # Start the neverending controller
        publishMatch firstRoute, params, options

        expect(beforeAction).toHaveBeenCalledOnce()
        expect(firstAction).not.toHaveBeenCalled()

        # While the promise is pending, start another controller
        publishMatch secondRoute, params, options

        expect(secondAction).toHaveBeenCalledOnce()

        # Test what happens when the Promise is resolved later
        dfd.resolve()
        waitsFor -> firstAction.callCount
        expect(firstAction).toHaveBeenCalledOnce()

        beforeAction.restore()
        firstAction.restore()
        secondAction.restore()
