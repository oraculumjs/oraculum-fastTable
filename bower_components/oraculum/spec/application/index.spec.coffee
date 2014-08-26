require [
  'oraculum'
  'oraculum/libs'
  'oraculum/application/index'
], (Oraculum) ->
  'use strict'

  describe 'Application', ->
    definition = Oraculum.definitions['Application']
    ctor = definition.constructor
    mockApplication = null

    containsMixins definition,
      'PubSub.Mixin'
      'Freezable.Mixin'
      'Disposable.Mixin'

    describe 'mixin configuration', ->
      it 'should set the disposeAll bit to true on the disposable mixin by default', ->
        expect(ctor::mixinOptions.disposable.disposeAll).toBeTrue()

    describe 'constructor', ->

      beforeEach ->
        mockApplication = mockFactoryInstance 'initRouter', 'initDispatcher',
          'initLayout', 'initComposer', 'initialize', 'start'

      it 'should invoke @initRouter with the correct arguments', ->
        ctor.call mockApplication, options = {'routes'}
        expect(mockApplication.initRouter).toHaveBeenCalledOnce()
        expect(mockApplication.initRouter.firstCall.args[0]).toBe 'routes'
        expect(mockApplication.initRouter.firstCall.args[1]).toBe options

      it 'should invoke @initDispatcher with the correct arguments', ->
        ctor.call mockApplication, options = {}
        expect(mockApplication.initDispatcher).toHaveBeenCalledOnce()
        expect(mockApplication.initDispatcher.firstCall.args[0]).toBe options

      it 'should invoke @initLayout with the correct arguments', ->
        ctor.call mockApplication, options = {}
        expect(mockApplication.initLayout).toHaveBeenCalledOnce()
        expect(mockApplication.initLayout.firstCall.args[0]).toBe options

      it 'should invoke @initComposer with the correct arguments', ->
        ctor.call mockApplication, options = {}
        expect(mockApplication.initComposer).toHaveBeenCalledOnce()
        expect(mockApplication.initComposer.firstCall.args[0]).toBe options

      it 'should invoke @initialize with the correct arguments', ->
        ctor.apply mockApplication, args = ['arg0']
        expect(mockApplication.initialize).toHaveBeenCalledOnce()
        expect(mockApplication.initialize.firstCall.args[0]).toBe 'arg0'

      it 'should invoke @start', ->
        ctor.call mockApplication
        expect(mockApplication.start).toHaveBeenCalledOnce()

    describe 'initRouter', ->

      beforeEach ->
        mockApplication = mockFactoryInstance()

      it 'should export an instance of Router as @router', ->
        ctor::initRouter.call mockApplication
        expect(mockApplication.router).toContain 'Router'
        ctor::initRouter.call mockApplication, null, options = {router: 'DifferentRouter'}
        expect(mockApplication.router).toContain 'DifferentRouter', options

      it 'should invoke the routes method, if provided, with the router\'s match method', ->
        mockApplication.__get = sinon.stub().withArgs('Router').returns {'match'}
        ctor::initRouter.call mockApplication, routes = sinon.stub()
        expect(routes).toHaveBeenCalledOnce()
        expect(routes).toHaveBeenCalledWith 'match'

    describe 'initDispatcher', ->

      beforeEach ->
        mockApplication = mockFactoryInstance()

      it 'should export an instance of Dispatcher as @dispatcher', ->
        ctor::initDispatcher.call mockApplication
        expect(mockApplication.dispatcher).toContain 'Dispatcher'
        ctor::initDispatcher.call mockApplication, options = {dispatcher: 'DifferentDispatcher'}
        expect(mockApplication.dispatcher).toContain 'DifferentDispatcher', options

    describe 'initLayout', ->

      beforeEach ->
        mockApplication = mockFactoryInstance()
        mockApplication.title = 'title'

      it 'should export an instance of Layout as @layout', ->
        ctor::initLayout.call mockApplication, options = {layout: 'Layout'}
        expect(options.title).toBe 'title'
        expect(mockApplication.layout).toContain 'Layout', options
        ctor::initLayout.call mockApplication, options = {layout: 'AlternateLayout'}
        expect(mockApplication.layout).toContain 'AlternateLayout', options

    describe 'initComposer', ->

      beforeEach ->
        mockApplication = mockFactoryInstance()

      it 'should export an instance of Composer as @composer', ->
        ctor::initComposer.call mockApplication
        expect(mockApplication.composer).toContain 'Composer'
        ctor::initComposer.call mockApplication, options = {composer: 'DifferentComposer'}
        expect(mockApplication.composer).toContain 'DifferentComposer', options

    describe 'initialize', ->
      it 'should throw an exception if the application was already started', ->
        mockApplication = { started: false }
        expect(-> ctor::initialize.call mockApplication).not.toThrow()
        mockApplication.started = true
        expect(-> ctor::initialize.call mockApplication).toThrow()

    describe 'start', ->

      beforeEach ->
        mockApplication = router: startHistory: sinon.stub()

      it 'should invoke startHistory on @router', ->
        ctor::start.call mockApplication
        expect(mockApplication.router.startHistory).toHaveBeenCalledOnce()

      it 'should set @started to true', ->
        ctor::start.call mockApplication
        expect(mockApplication.started).toBeTrue()
