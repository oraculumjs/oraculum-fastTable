# Unit tests ported from Chaplin
require [
  'oraculum'
  'oraculum/libs'
  'oraculum/application/composer'
  'oraculum/mixins/callback-provider'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'
  Backbone = Oraculum.get 'Backbone'
  {executeCallback} = Oraculum.mixins['CallbackDelegate.Mixin']

  describe 'Composer', ->
    definition = Oraculum.definitions['Composer']
    ctor = definition.constructor

    composer = null
    dispatcher = null

    Model = Oraculum.getConstructor 'Model'
    Composer = Oraculum.getConstructor 'Composer'
    Composition = Oraculum.getConstructor 'Composition'

    TestView1 = Oraculum.extend('View', 'TestView1', {}).getConstructor 'TestView1'
    TestView2 = Oraculum.extend('View', 'TestView2', {}).getConstructor 'TestView2'
    TestView3 = Oraculum.extend('View', 'TestView3', {}).getConstructor 'TestView3'
    TestView4 = Oraculum.extend('View', 'TestView4', {}).getConstructor 'TestView4'

    keys = Object.keys or _.keys

    beforeEach ->
      composer = new Composer

    afterEach ->
      composer.dispose()

    containsMixins definition,
      'PubSub.Mixin'
      'Listener.Mixin'
      'Disposable.Mixin'
      'CallbackProvider.Mixin'

    it 'should initialize', ->
      expect(composer.compositions).toEqual {}

    # composing with the short form
    # -----------------------------

    it 'should initialize a view when it is composed for the first time', ->
      executeCallback 'composer:compose', 'test1', TestView1
      expect(keys(composer.compositions).length).toBe 1
      expect(composer.compositions['test1'].item).toBeInstanceOf TestView1
      Backbone.trigger 'dispatcher:dispatch'

      executeCallback 'composer:compose', 'test1', TestView1
      executeCallback 'composer:compose', 'test2', TestView2
      expect(keys(composer.compositions).length).toBe 2
      expect(composer.compositions['test2'].item).toBeInstanceOf TestView2
      Backbone.trigger 'dispatcher:dispatch'

    it 'should not initialize a view if it is already composed', ->
      executeCallback 'composer:compose', 'test1', TestView1
      expect(keys(composer.compositions).length).toBe 1
      Backbone.trigger 'dispatcher:dispatch'

      executeCallback 'composer:compose', 'test1', TestView1
      executeCallback 'composer:compose', 'test2', TestView2
      expect(keys(composer.compositions).length).toBe 2
      Backbone.trigger 'dispatcher:dispatch'

      executeCallback 'composer:compose', 'test1', TestView1
      executeCallback 'composer:compose', 'test2', TestView2
      executeCallback 'composer:compose', 'test1', TestView1
      expect(keys(composer.compositions).length).toBe 2
      Backbone.trigger 'dispatcher:dispatch'

    it 'should dispose a compose view if it is not re-composed', ->
      executeCallback 'composer:compose', 'test1', TestView1
      expect(keys(composer.compositions).length).toBe 1

      Backbone.trigger 'dispatcher:dispatch'
      executeCallback 'composer:compose', 'test2', TestView2
      Backbone.trigger 'dispatcher:dispatch'

      expect(keys(composer.compositions).length).toBe 1
      expect(composer.compositions['test2'].item).toBeInstanceOf TestView2

    # # composing with the long form
    # # -----------------------------

    it 'should invoke compose when a view should be composed', ->
      executeCallback 'composer:compose', 'weird',
        compose: -> @view = new TestView1()
        check: -> false

      expect(keys(composer.compositions).length).toBe 1
      expect(composer.compositions['weird'].view).toBeInstanceOf TestView1

      Backbone.trigger 'dispatcher:dispatch'
      expect(keys(composer.compositions).length).toBe 1

      executeCallback 'composer:compose', 'weird',
        compose: -> @view = new TestView2()

      Backbone.trigger 'dispatcher:dispatch'
      expect(keys(composer.compositions).length).toBe 1
      expect(composer.compositions['weird'].view).toBeInstanceOf TestView2

    it 'should dispose the entire composition when necessary', ->
      spy = sinon.spy()

      executeCallback 'composer:compose', 'weird',
        compose: ->
          @dagger = new TestView1()
          @dagger2 = new TestView1()
        check: -> false

      expect(keys(composer.compositions).length).toBe 1
      expect(composer.compositions['weird'].dagger).toBeInstanceOf TestView1

      Backbone.trigger 'dispatcher:dispatch'
      expect(keys(composer.compositions).length).toBe 1

      executeCallback 'composer:compose', 'weird',
        compose: -> @frozen = new TestView2()
        check: -> false

      Backbone.trigger 'dispatcher:dispatch'
      expect(keys(composer.compositions).length).toBe 1
      expect(composer.compositions['weird'].frozen).toBeInstanceOf TestView2

      Backbone.trigger 'dispatcher:dispatch'
      expect(keys(composer.compositions).length).toBe 0

    it 'should allow a function to be composed', ->
      spy = sinon.spy()

      executeCallback 'composer:compose', 'spy', spy
      Backbone.trigger 'dispatcher:dispatch'

      expect(spy).toHaveBeenCalledOnce()

    it 'should allow a function to be composed with options', ->
      spy = sinon.spy()
      params = {foo: 123, bar: 123}

      executeCallback 'composer:compose', 'spy', params, spy
      Backbone.trigger 'dispatcher:dispatch'

      expect(spy).toHaveBeenCalledWith(params)

    it 'should allow a options hash with a function to be composed with options', ->
      spy = sinon.spy()
      params = {foo: 123, bar: 123}

      executeCallback 'composer:compose', 'spy',
        options: params
        compose: spy

      Backbone.trigger 'dispatcher:dispatch'

      expect(spy).toHaveBeenCalledWith params

    it 'should allow a model to be composed', ->
      executeCallback 'composer:compose', 'spy', Model

      expect(composer.compositions['spy'].item).toBeInstanceOf Model

      Backbone.trigger 'dispatcher:dispatch'

    it 'should allow a composition to be composed', ->
      spy = sinon.spy()

      CustomComposition = Oraculum.extend('Composition', 'CustomComposition', {
        compose: spy
      }, {
        override: true
        inheritMixins: true
      }).getConstructor 'CustomComposition'

      executeCallback 'composer:compose', 'spy', CustomComposition
      Backbone.trigger 'dispatcher:dispatch'

      expect(composer.compositions['spy'].item).toBeInstanceOf Composition
      expect(composer.compositions['spy'].item).toBeInstanceOf CustomComposition

      expect(spy).toHaveBeenCalledOnce()

    it 'should allow a composition to be composed with options', ->
      spy = sinon.spy()
      params = {foo: 123, bar: 123}

      CustomComposition = Oraculum.extend('Composition', 'CustomComposition', {
        compose: spy
      }, {
        override: true
        inheritMixins: true
      }).getConstructor 'CustomComposition'

      executeCallback 'composer:compose', 'spy', CustomComposition, params
      Backbone.trigger 'dispatcher:dispatch'

      expect(composer.compositions['spy'].item).toBeInstanceOf Composition
      expect(composer.compositions['spy'].item).toBeInstanceOf CustomComposition

      expect(spy).toHaveBeenCalledOnce()
      expect(spy).toHaveBeenCalledWith params

    it 'should allow a composition to be retreived', ->
      executeCallback 'composer:compose', 'spy', Model
      executeCallback 'composer:retrieve', 'spy', (item) =>
        expect(item).toBe composer.compositions['spy'].item
        Backbone.trigger 'dispatcher:dispatch'

    it 'should throw for invalid invocations', ->
      expect(->
        executeCallback 'composer:compose', 'spy', null
      ).toThrow()
      expect(->
        executeCallback 'composer:compose', compose: /a/, check: ''
      ).toThrow()
