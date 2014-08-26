require [
  'oraculum'
  'oraculum/mixins/disposable'
  'oraculum/mixins/callback-provider'
], (Oraculum) ->
  'use strict'

  provideCallback = Oraculum.mixins['CallbackProvider.Mixin'].provideCallback
  removeCallbacks = Oraculum.mixins['CallbackProvider.Mixin'].removeCallbacks
  executeCallback = Oraculum.mixins['CallbackDelegate.Mixin'].executeCallback

  describe 'CallbackProvider.Mixin, CallbackDelegate.Mixin', ->
    view = null
    callback1 = null
    callback2 = sinon.stub()

    Oraculum.extend 'View', 'CallbackProvider.View', {
      mixinOptions:
        provideCallbacks:
          callback1: '_callback1'
          callback2: callback2
      _callback1: -> callback1()
    }, mixins: [
      'Disposable.Mixin'
      'CallbackProvider.Mixin'
    ]

    beforeEach ->
      callback1 = sinon.stub()
      view = Oraculum.get 'CallbackProvider.View'

    afterEach ->
      view.dispose()
      callback2.reset()
      removeCallbacks()

    it 'should provide callbacks as configured', ->
      executeCallback 'callback1'
      executeCallback 'callback2'
      expect(callback1).toHaveBeenCalledOnce()
      expect(callback2).toHaveBeenCalledOnce()
      expect(callback2).toHaveBeenCalledOn view

    it 'should provide a single callback', ->
      stub = sinon.stub()
      view.provideCallback 'stub', stub, sinon
      executeCallback 'stub'
      expect(stub).toHaveBeenCalledOnce()
      expect(stub).toHaveBeenCalledOn sinon

    it 'should throw an error for an invalid callback', ->
      Oraculum.extend 'View', 'InvalidCallbackProvider.View', {
      mixinOptions: provideCallbacks: callback: 'noSuchFunction'
      }, mixins: ['Disposable.Mixin','CallbackProvider.Mixin']
      expect(-> view.provideCallback()).toThrow()
      expect(-> view.provideCallback null).toThrow()
      expect(-> view.provideCallback 'string', null).toThrow()
      expect(-> view.provideCallback 'string', 'string').toThrow()
      view.dispose()
      expect(-> Oraculum.get 'InvalidCallbackProvider.View').toThrow()

    it 'should remove callbacks by name', ->
      executeCallback 'callback1'
      executeCallback 'callback2'
      expect(callback1).toHaveBeenCalledOnce()
      expect(callback2).toHaveBeenCalledOnce()
      view.removeCallbacks ['callback1']
      expect(-> executeCallback 'callback1').toThrow()
      expect(-> executeCallback 'callback2').not.toThrow()
      expect(callback1).toHaveBeenCalledOnce()
      expect(callback2).toHaveBeenCalledTwice()

    it 'should remove callbacks by instance', ->
      callback3 = sinon.stub()
      provideCallback 'callback3', callback3, sinon
      executeCallback 'callback1'
      executeCallback 'callback2'
      executeCallback 'callback3'
      expect(callback1).toHaveBeenCalledOnce()
      expect(callback2).toHaveBeenCalledOnce()
      expect(callback3).toHaveBeenCalledOnce()
      view.removeCallbacks view
      expect(-> executeCallback 'callback1').toThrow()
      expect(-> executeCallback 'callback2').toThrow()
      expect(-> executeCallback 'callback3').not.toThrow()
      expect(callback1).toHaveBeenCalledOnce()
      expect(callback2).toHaveBeenCalledOnce()
      expect(callback3).toHaveBeenCalledTwice()

    it 'should not throw an error for an invalid callback if silent', ->
      expect(-> executeCallback 'name').toThrow()
      expect(-> executeCallback {'name', silent: false}).toThrow()
      expect(-> executeCallback {'name', silent: true}).not.toThrow()

    it 'should pass arguments to the callback', ->
      provideCallback 'arguments', args = sinon.stub()
      executeCallback 'arguments', 1, 2, 3, 4, 5
      expect(args).toHaveBeenCalledWith 1, 2, 3, 4, 5

    it 'should return the result of the callback', ->
      provideCallback 'result', -> 'result'
      expect(executeCallback 'result').toBe 'result'
