require [
  'oraculum'
  'oraculum/libs'
  'oraculum/application/route'
  'oraculum/application/router'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'
  Backbone = Oraculum.get 'Backbone'
  removeCallbacks = Oraculum.mixins['CallbackProvider.Mixin'].removeCallbacks
  executeCallback = Oraculum.mixins['CallbackDelegate.Mixin'].executeCallback

  describe 'Router and Route', ->
    routeConstructor = Oraculum.definitions.Route.constructor

    Route = Oraculum.getConstructor 'Route'
    Router = Oraculum.getConstructor 'Router'

    # Initialize shared variables
    router = passedRoute = passedParams = passedOptions = null

    # router:match handler to catch the arguments
    routerMatch = (_route, _params, _options) ->
      passedRoute = _route
      passedParams = _params
      passedOptions = _options

    # Helper for creating params/options to compare with
    create = ->
      _.extend {}, arguments...

    # Create a fresh Router with a fresh Backbone.History before each test
    beforeEach ->
      removeCallbacks()
      router = new Router randomOption: 'foo', pushState: false
      Backbone.on 'router:match', routerMatch

    afterEach ->
      router.dispose()
      passedRoute = passedParams = passedOptions = null
      Backbone.off 'router:match', routerMatch

    containsMixins Oraculum.definitions['Route'],
      'PubSub.Mixin',
      'Freezable.Mixin'

    containsMixins Oraculum.definitions['Router'],
      'PubSub.Mixin'
      'Listener.Mixin'
      'Disposable.Mixin'
      'CallbackProvider.Mixin'

    describe 'Interaction with Backbone.History', ->

      it 'should create a Backbone.History instance', ->
        expect(Backbone.history).toBeInstanceOf Backbone.History

      it 'should not start the Backbone.History at once', ->
        expect(Backbone.History.started).toBeFalse()

      it 'should allow to start the Backbone.History', ->
        spy = sinon.spy Backbone.history, 'start'
        expect(router.startHistory).toBeFunction()
        router.startHistory()
        expect(Backbone.History.started).toBeTrue()
        expect(spy).toHaveBeenCalled()
        spy.restore()

      it 'should default to pushState', ->
        router.startHistory()
        expect(router.options).toBeObject()
        expect(Backbone.history.options.pushState).toBe router.options.pushState

      it 'should default to root', ->
        router.startHistory()
        expect(router.options).toBeObject()
        expect(Backbone.history.options.root).toBe router.options.root

      it 'should pass the options to the Backbone.History instance', ->
        router.startHistory()
        expect(Backbone.history.options.randomOption).toBe 'foo'

      it 'should allow to stop the Backbone.History', ->
        router.startHistory()
        spy = sinon.spy Backbone.history, 'stop'
        expect(router.stopHistory).toBeFunction()
        router.stopHistory()
        expect(Backbone.History.started).toBeFalse()
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe 'Creating Routes', ->

      it 'should have a match method which returns a route', ->
        expect(router.match).toBeFunction()
        route = router.match '', 'null#null'
        expect(route).toBeInstanceOf Route

      it 'should reject reserved controller action names', ->
        for prop in ['constructor', 'initialize', 'redirectTo']
          expect(-> router.match '', "null##{prop}").toThrow()

      it 'should allow specifying controller and action in options', ->
        # Signature: url, 'controller#action', options
        url = 'url'
        options = {}
        router.match url, 'c#a', options
        route = Backbone.history.handlers[0].route
        expect(route.controller).toBe 'c'
        expect(route.action).toBe 'a'
        expect(route.url).toBe options.url

        # Signature: url, { controller, action }
        url = 'url'
        options = controller: 'c', action: 'a'
        router.match url, options
        route = Backbone.history.handlers[1].route
        expect(route.controller).toBe 'c'
        expect(route.action).toBe 'a'
        expect(route.url).toBe options.url

        # Handle errors
        expect(->
          router.match 'url', 'null#null', controller: 'c', action: 'a'
        ).toThrow()
        expect(->
          router.match 'url', {}
        ).toThrow()

      it 'should pass trailing option from Router by default', ->
        url = 'url'
        target = 'c#a'

        route = router.match url, target
        expect(route.options.trailing).toBe router.options.trailing

        router.options.trailing = true

        route = router.match url, target
        expect(route.options.trailing).toBeTrue()

        route = router.match url, target, trailing: null
        expect(route.options.trailing).toBe null

    describe 'Routing', ->

      it 'should fire a router:match event when a route matches', ->
        spy = sinon.spy()
        Backbone.on 'router:match', spy
        router.match '', 'null#null'

        router.route url: '/'
        expect(spy).toHaveBeenCalled()

      it 'should match route names, both default and custom', ->
        spy = sinon.spy()
        Backbone.on 'router:match', spy
        router.match 'correct-match1', 'controller#action'
        router.match 'correct-match2', 'null#null', name: 'routeName'

        routed1 = router.route 'controller#action'
        routed2 = router.route 'routeName'

        expect(routed1 and routed2).toBeTrue()
        expect(spy).toHaveBeenCalledTwice()

        Backbone.off 'router:match', spy

      it 'should match URLs correctly', ->
        spy = sinon.spy()
        Backbone.on 'router:match', spy
        router.match 'correct-match1', 'null#null'
        router.match 'correct-match2', 'null#null'

        routed = router.route url: '/correct-match1'
        expect(routed).toBeTrue()
        expect(spy).toHaveBeenCalledOnce()

        Backbone.off 'router:match', spy

      it 'should match configuration objects', ->
        spy = sinon.spy()
        Backbone.on 'router:match', spy
        router.match 'correct-match', 'null#null'
        router.match 'correct-match-with-name', 'null#null', name: 'null'
        router.match 'correct-match-with/:named_param', 'null#null', name: 'with-param'

        routed1 = router.route controller: 'null', action: 'null'
        routed2 = router.route name: 'null'

        expect(routed1 and routed2).toBeTrue()
        expect(spy).toHaveBeenCalledTwice()

        Backbone.off 'router:match', spy

      it 'should match correctly when using the root option', ->
        removeCallbacks()
        subdirRooter = new Router randomOption: 'foo', pushState: false, root: '/subdir/'
        spy = sinon.spy()
        Backbone.on 'router:match', spy
        subdirRooter.match 'correct-match1', 'null#null'
        subdirRooter.match 'correct-match2', 'null#null'

        routed = subdirRooter.route url: '/subdir/correct-match1'
        expect(routed).toBeTrue()
        expect(spy).toHaveBeenCalledOnce()

        Backbone.off 'router:match', spy
        subdirRooter.dispose()

      it 'should match in order specified', ->
        spy = sinon.spy()
        Backbone.on 'router:match', spy
        router.match 'params/:one', 'null#null'
        router.match 'params/:two', 'null#null'

        routed = router.route url: '/params/1'

        expect(routed).toBeTrue()
        expect(spy).toHaveBeenCalledOnce()
        expect(passedParams).toBeObject()
        expect(passedParams.one).toBe '1'
        expect(passedParams.two).toBe undefined

        Backbone.off 'router:match', spy

      it 'should match in order specified when called by Backbone.History', ->
        spy = sinon.spy()
        Backbone.on 'router:match', spy
        router.match 'params/:one', 'null#null'
        router.match 'params/:two', 'null#null'

        router.startHistory()
        routed = Backbone.history.loadUrl '/params/1'

        expect(routed).toBeTrue()
        expect(spy).toHaveBeenCalledOnce()
        expect(passedParams).toBeObject()
        expect(passedParams.one).toBe '1'
        expect(passedParams.two).toBe undefined

        Backbone.off 'router:match', spy

      it 'should identically match URLs that differ only by trailing slash', ->
        router.match 'url', 'null#null'

        routed = router.route url: 'url/'
        expect(routed).toBeTrue()

        routed = router.route url: 'url/?'
        expect(routed).toBeTrue()

        routed = router.route url: 'url/?key=val'
        expect(routed).toBeTrue()

      it 'should leave trailing slash accordingly to current options', ->
        router.match 'url', 'null#null', trailing: null
        routed = router.route url: 'url/'
        expect(routed).toBeTrue()
        expect(passedRoute).toBeObject()
        expect(passedRoute.path).toBe 'url/'

      it 'should remove trailing slash accordingly to current options', ->
        router.match 'url', 'null#null', trailing: false
        routed = router.route url: 'url/'
        expect(routed).toBeTrue()
        expect(passedRoute).toBeObject()
        expect(passedRoute.path).toBe 'url'

      it 'should add trailing slash accordingly to current options', ->
        router.match 'url', 'null#null', trailing: true
        routed = router.route url: 'url'
        expect(routed).toBeTrue()
        expect(passedRoute).toBeObject()
        expect(passedRoute.path).toBe 'url/'

    describe 'Passing the Route', ->

      it 'should pass the route to the router:match handler', ->
        router.match 'passing-the-route', 'controller#action'
        router.route 'controller#action'
        expect(passedRoute).toBeObject()
        expect(passedRoute.path).toBe 'passing-the-route'
        expect(passedRoute.controller).toBe 'controller'
        expect(passedRoute.action).toBe 'action'

      it 'should handle optional parameters', ->
        router.match 'items(/missing/:missing)(/present/:present)', 'controller#action'
        router.route url: '/items/present/1'
        expect(passedRoute).toBeObject()
        expect(passedRoute.path).toBe 'items/present/1'
        expect(passedRoute.controller).toBe 'controller'
        expect(passedRoute.action).toBe 'action'

    describe 'Passing the Parameters', ->

      it 'should extract named parameters from URL', ->
        router.match 'params/:one/:p_two_123/three', 'null#null'
        router.route url: '/params/123-foo/456-bar/three'
        expect(passedParams).toBeObject()
        expect(passedParams.one).toBe '123-foo'
        expect(passedParams.p_two_123).toBe '456-bar'

      it 'should extract named parameters from object', ->
        router.match 'params/:one/:p_two_123/three', 'controller#action'
        router.route 'controller#action', one: '123-foo', p_two_123: '456-bar'
        expect(passedParams).toBeObject()
        expect(passedParams.one).toBe '123-foo'
        expect(passedParams.p_two_123).toBe '456-bar'

      it 'should extract non-ascii named parameters', ->
        router.match 'params/:one/:two/:three/:four', 'null#null'
        router.route url: "/params/o_O/*.*/ü~ö~ä/#{encodeURIComponent('éêè')}"
        expect(passedParams).toBeObject()
        expect(passedParams.one).toBe 'o_O'
        expect(passedParams.two).toBe '*.*'
        expect(passedParams.three).toBe 'ü~ö~ä'
        expect(passedParams.four).toBe encodeURIComponent('éêè')

      it 'should match splat parameters', ->
        router.match 'params/:one/*two', 'null#null'
        router.route url: '/params/123-foo/456-bar/789-qux'
        expect(passedParams).toBeObject()
        expect(passedParams.one).toBe '123-foo'
        expect(passedParams.two).toBe '456-bar/789-qux'

      it 'should match splat parameters at the beginning', ->
        router.match 'params/*one/:two', 'null#null'
        router.route url: '/params/123-foo/456-bar/789-qux'
        expect(passedParams).toBeObject()
        expect(passedParams.one).toBe '123-foo/456-bar'
        expect(passedParams.two).toBe '789-qux'

      it 'should match splat parameters before a named parameter', ->
        router.match 'params/*one:two', 'null#null'
        router.route url: '/params/123-foo/456-bar/789-qux'
        expect(passedParams).toBeObject()
        expect(passedParams.one).toBe '123-foo/456-bar/'
        expect(passedParams.two).toBe '789-qux'

      it 'should match optional named parameters', ->
        router.match 'items/:type(/page/:page)(/min/:min/max/:max)', 'null#null'

        router.route url: '/items/clothing'
        expect(passedParams).toBeObject()
        expect(passedParams.type).toBe 'clothing'
        expect(passedParams.page).toBe undefined
        expect(passedParams.min).toBe undefined
        expect(passedParams.max).toBe undefined

        router.route url: '/items/clothing/page/5'
        expect(passedParams).toBeObject()
        expect(passedParams.type).toBe 'clothing'
        expect(passedParams.page).toBe '5'
        expect(passedParams.min).toBe undefined
        expect(passedParams.max).toBe undefined

        router.route url: '/items/clothing/min/10/max/20'
        expect(passedParams).toBeObject()
        expect(passedParams.type).toBe 'clothing'
        expect(passedParams.page).toBe undefined
        expect(passedParams.min).toBe '10'
        expect(passedParams.max).toBe '20'

      it 'should match optional splat parameters', ->
        router.match 'items(/*slug)', 'null#null'

        routed = router.route url: '/items'
        expect(routed).toBeTrue()
        expect(passedParams).toBeObject()
        expect(passedParams.slug).toBe undefined

        routed = router.route url: '/items/5-boots'
        expect(routed).toBeTrue()
        expect(passedParams).toBeObject()
        expect(passedParams.slug).toBe '5-boots'

      it 'should pass fixed parameters', ->
        router.match 'fixed-params/:id', 'null#null',
          params:
            foo: 'bar'

        router.route url: '/fixed-params/123'
        expect(passedParams).toBeObject()
        expect(passedParams.id).toBe '123'
        expect(passedParams.foo).toBe 'bar'

      it 'should not overwrite fixed parameters', ->
        router.match 'conflicting-params/:foo', 'null#null',
          params:
            foo: 'bar'

        router.route url: '/conflicting-params/123'
        expect(passedParams.foo).toBe 'bar'

      it 'should impose parameter constraints', ->
        spy = sinon.spy()
        Backbone.on 'router:match', spy
        router.match 'constraints/:id', 'controller#action',
          constraints:
            id: /^\d+$/

        expect(-> router.route url: '/constraints/123-foo').toThrow()
        expect(-> router.route 'controller#action', id: '123-foo').toThrow()

        router.route url: '/constraints/123'
        router.route 'controller#action', id: 123
        expect(spy).toHaveBeenCalledTwice()

        Backbone.off 'router:match', spy

      it 'should deny regular expression as pattern', ->
        expect(-> router.match /url/, 'null#null').toThrow()

    describe 'Route Matching', ->

      it 'should not initialize when route name has "#"', ->
        expect(->
          new Route 'params', 'null', 'null', name: 'null#null'
        ).toThrow()
      it 'should not initialize when using existing controller attr', ->
        expect(->
          new Route 'params', 'null', 'beforeAction'
        ).toThrow()

      it 'should compare route value', ->
        route = new Route 'params', 'hello', 'world'
        expect(route.matches 'hello#world').toBeTrue()
        expect(route.matches controller: 'hello', action: 'world').toBeTrue()
        expect(route.matches name: 'hello#world').toBeTrue()

        expect(route.matches 'hello#worldz').toBeFalse()
        expect(route.matches controller: 'hello', action: 'worldz').toBeFalse()
        expect(route.matches name: 'hello#worldz').toBeFalse()

    describe 'Route Reversal', ->

      it 'should allow for reversing a route instance to get its url', ->
        route = new Route 'params', 'null', 'null'
        url = route.reverse()
        expect(url).toBe 'params'

      it 'should allow for reversing a route instance with object to get its url', ->
        route = new Route 'params/:two', 'null', 'null'
        url = route.reverse two: 1151
        expect(url).toBe 'params/1151'

        route = new Route 'params/:two/:one/*other/:another', 'null', 'null'
        url = route.reverse
          two: 32
          one: 156
          other: 'someone/out/there'
          another: 'meh'
        expect(url).toBe 'params/32/156/someone/out/there/meh'

      it 'should allow for reversing a route instance with array to get its url', ->
        route = new Route 'params/:two', 'null', 'null'
        url = route.reverse [1151]
        expect(url).toBe 'params/1151'

        route = new Route 'params/:two/:one/*other/:another', 'null', 'null'
        url = route.reverse [32, 156, 'someone/out/there', 'meh']
        expect(url).toBe 'params/32/156/someone/out/there/meh'

      it 'should allow for reversing optional route params', ->
        route = new Route 'items/:id(/page/:page)(/sort/:sort)', 'null', 'null'
        url = route.reverse id: 5, page: 2, sort: 'price'
        expect(url).toBe 'items/5/page/2/sort/price'

        route = new Route 'items/:id(/page/:page/sort/:sort)', 'null', 'null'
        url = route.reverse id: 5, page: 2, sort: 'price'
        expect(url).toBe 'items/5/page/2/sort/price'

      it 'should allow for reversing a route instance with optional splats', ->
        route = new Route 'items/:id(-*slug)', 'null', 'null'
        url = route.reverse id: 5, slug: "shirt"
        expect(url).toBe 'items/5-shirt'

      it 'should handle partial fulfillment of optional portions', ->
        route = new Route 'items/:id(/page/:page)(/sort/:sort)', 'null', 'null'
        url = route.reverse id: 5, page: 2
        expect(url).toBe 'items/5/page/2'

        route = new Route 'items/:id(/page/:page/sort/:sort)', 'null', 'null'
        url = route.reverse id: 5, page: 2
        expect(url).toBe 'items/5'

      it 'should handle partial fulfillment of optional splats', ->
        route = new Route 'items/:id(-*slug)(/:section)', 'null', 'null'
        url = route.reverse id: 5, section: 'comments'
        expect(url).toBe 'items/5/comments'
        url = route.reverse id: 5, slug: 'boots'
        expect(url).toBe 'items/5-boots'
        url = route.reverse id: 5, slug: 'boots', section: 'comments'
        expect(url).toBe 'items/5-boots/comments'

        route = new Route 'items/:id(-*slug/:desc)', 'null', 'null'
        url = route.reverse id: 5, slug: 'shirt'
        expect(url).toBe 'items/5'
        url = route.reverse id: 5, slug: 'shirt', desc: 'brand new'
        expect(url).toBe 'items/5-shirt/brand new'

      it 'should reject reversals when there are not enough params', ->
        route = new Route 'params/:one/:two', 'null', 'null'
        expect(route.reverse [1]).toEqual false
        expect(route.reverse one: 1).toEqual false
        expect(route.reverse two: 2).toEqual false
        expect(route.reverse()).toEqual false

      it 'should add trailing slash accordingly to current options', ->
        route = new Route 'params', 'null', 'null', trailing: true
        url = route.reverse()
        expect(url).toBe 'params/'

    describe 'Router reversing', ->
      register = ->
        router.match 'index', 'null#1', name: 'home'
        router.match 'phone/:one', 'null#2', name: 'phonebook'
        router.match 'params/:two', 'null#2', name: 'about'
        router.match 'fake/:three', 'fake#2', name: 'about'
        router.match 'phone/:four', 'null#a'

      it 'should allow for registering routes with a name', ->
        register()
        names = for handler in Backbone.history.handlers
          handler.route.name
        expect(names).toEqual ['home', 'phonebook', 'about', 'about', 'null#a']

      it 'should allow for reversing a route by its default name', ->
        register()
        url = router.reverse 'null#a', {four: 41}
        expect(url).toBe '/phone/41'

      it 'should allow for reversing a route by its custom name', ->
        register()
        url = router.reverse 'phonebook', one: 145
        expect(url).toBe '/phone/145'

        expect(-> router.reverse 'missing', one: 145).toThrow()

      it 'should report the given criteria if reversal fails', ->
        register()
        expect(-> router.reverse 'missing').toThrow()

      it 'should allow for reversing a route by its controller', ->
        register()
        url = router.reverse controller: 'null'
        expect(url).toBe '/index'

      it 'should allow for reversing a route by its controller and action', ->
        register()
        url = router.reverse {controller: 'null', action: '2'}, {two: 41}
        expect(url).toBe '/params/41'

      it 'should allow for reversing a route by its controller and name', ->
        register()
        url = router.reverse {name: 'about', controller: 'fake'}, {three: 41}
        expect(url).toBe '/fake/41'

      it 'should allow for reversing a route by its name via event', ->
        register()
        params = one: 145
        spy = sinon.spy()
        expect(executeCallback 'router:reverse', 'phonebook', params).toBe '/phone/145'

        expect(->
          executeCallback 'router:reverse', 'missing', params
        ).toThrow()

      it 'should prepend mount point', ->
        router.dispose()
        Backbone.off 'router:match', routerMatch

        removeCallbacks()
        router = new Router randomOption: 'foo', pushState: false, root: '/subdir/'
        Backbone.on 'router:match', routerMatch
        register()

        params = one: 145
        res = executeCallback 'router:reverse', 'phonebook', params
        expect(res).toBe '/subdir/phone/145'

    describe 'Query string extraction', ->

      it 'should extract query string parameters from an url', ->
        router.match 'query-string', 'null#null'

        input =
          foo: '123 456'
          'b a r': 'the _quick &brown föx= jumps over the lazy dáwg'
          'q&uu=x': 'the _quick &brown föx= jumps over the lazy dáwg'
        query = routeConstructor.stringifyQueryParams input

        router.route url: 'query-string?' + query
        expect(passedOptions.query).toEqual input

      it 'should extract query string parameters from an object', ->
        router.match 'query-string', 'controller#action'

        input =
          foo: '123 456'
          'b a r': 'the _quick &brown föx= jumps over the lazy dáwg'
          'q&uu=x': 'the _quick &brown föx= jumps over the lazy dáwg'

        router.route 'controller#action', null, {query: input}
        expect(passedOptions.query).toEqual input

    describe 'Passing the Routing Options', ->

      it 'should pass routing options', ->
        router.match ':id', 'controller#action'
        query = x: 32, y: 21
        options = foo: 123, bar: 456
        router.route 'controller#action', ['foo'], create {query}, options
        # It should be a different object
        expect(passedOptions).not.toBe options
        expect(passedRoute.path).toBe 'foo'
        expect(passedRoute.query).toBe 'x=32&y=21'
        expect(passedOptions).toEqual(
          create(options, changeURL: true, query: query)
        )

    describe 'Setting the router:route handler', ->

      it 'should route when receiving a path', ->
        path = 'router-route-event'
        options = replace: true

        routeSpy = sinon.spy router, 'route'
        router.match path, 'router#route'

        executeCallback 'router:route', url: path, options
        expect(passedRoute).toBeObject()
        expect(passedRoute.controller).toBe 'router'
        expect(passedRoute.action).toBe 'route'
        expect(passedRoute.path).toBe path
        expect(passedOptions).toEqual(
          create(options, {changeURL: true})
        )

        expect(->
          executeCallback 'router:route', 'different-path', options
        ).toThrow()

        routeSpy.restore()

      it 'should route when receiving a name', ->

        router.match '', 'home#index', name: 'home'
        executeCallback 'router:route', name: 'home'

        expect(passedRoute.controller).toBe 'home'
        expect(passedRoute.action).toBe 'index'
        expect(passedRoute.path).toBe ''
        expect(passedParams).toBeObject()

      it 'should route when receiving both name and params', ->
        router.match 'phone/:id', 'phonebook#dial', name: 'phonebook'

        params = id: '123'
        executeCallback 'router:route', 'phonebook', params
        expect(passedRoute.controller).toBe 'phonebook'
        expect(passedRoute.action).toBe 'dial'
        expect(passedRoute.path).toBe "phone/#{params.id}"
        expect(passedParams).not.toBe params
        expect(passedParams).toBeObject()
        expect(passedParams.id).toBe params.id

      it 'should route when receiving controller and action name', ->
        router.match '', 'home#index'
        executeCallback 'router:route', controller: 'home', action: 'index'

        expect(passedRoute.controller).toBe 'home'
        expect(passedRoute.action).toBe 'index'
        expect(passedRoute.path).toBe ''
        expect(passedParams).toBeObject()

      it 'should route when receiving controller and action name and params', ->
        router.match 'phone/:id', 'phonebook#dial'

        params = id: '123'
        executeCallback 'router:route', controller: 'phonebook', action: 'dial', params
        expect(passedRoute.controller).toBe 'phonebook'
        expect(passedRoute.action).toBe 'dial'
        expect(passedRoute.path).toBe "phone/#{params.id}"
        expect(passedParams).not.toBe params
        expect(passedParams).toBeObject()
        expect(passedParams.id).toBe params.id

      it 'should pass options and call the callback', ->
        router.match 'index', 'null#null', name: 'home'
        router.match 'phone/:id', 'phonebook#dial', name: 'phonebook'

        params = id: '123'
        options = replace: true
        executeCallback 'router:route', 'phonebook', params, options

        expect(passedRoute.controller).toBe 'phonebook'
        expect(passedRoute.action).toBe 'dial'
        expect(passedRoute.path).toBe "phone/#{params.id}"
        expect(passedParams).not.toBe params
        expect(passedParams).toBeObject()
        expect(passedParams.id).toBe params.id
        expect(passedOptions).not.toBe options
        expect(passedOptions).toEqual(
          create(options, options,
            changeURL: true
          )
        )

      it 'should throw an error when no match was found', ->
        expect(->
          executeCallback 'router:route', 'phonebook'
        ).toThrow()

    describe 'Changing the URL', ->

      it 'should forward changeURL routing options to Backbone', ->
        path = 'router-changeurl-options'
        changeURL = sinon.spy router, 'changeURL'
        navigate = sinon.spy Backbone.history, 'navigate'
        options = some: 'stuff', changeURL: true

        router.changeURL null, null, {path}, options
        expect(navigate).toHaveBeenCalledWith path,
          replace: false, trigger: false

        forwarding = replace: true, trigger: true
        router.changeURL null, null, {path}, create(options, forwarding)
        expect(navigate).toHaveBeenCalledWith path, forwarding

        changeURL.restore()
        navigate.restore()

      it 'should not adjust the URL if not desired', ->
        path = 'router-changeurl-false'
        changeURL = sinon.spy router, 'changeURL'
        navigate = sinon.spy Backbone.history, 'navigate'

        router.changeURL null, null, {path}, changeURL: false
        expect(navigate).not.toHaveBeenCalled()

        changeURL.restore()
        navigate.restore()

      it 'should add the query string when adjusting the URL', ->
        path = 'my-little-path'
        query = 'foo=bar'
        changeURL = sinon.spy router, 'changeURL'
        navigate = sinon.spy Backbone.history, 'navigate'

        router.changeURL null, null, {path, query}, changeURL: true
        expect(navigate).toHaveBeenCalledWith "#{path}?#{query}"

        changeURL.restore()
        navigate.restore()
