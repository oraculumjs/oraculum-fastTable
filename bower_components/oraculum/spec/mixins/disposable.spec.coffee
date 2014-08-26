require [
  'oraculum'
  'oraculum/mixins/disposable'
], (Oraculum) ->
  'use strict'

  describe 'Disposable.Mixin', ->
    view = null

    Oraculum.extend 'View', 'Disposable.View', {}, mixins: ['Disposable.Mixin']

    beforeEach ->
      view = Oraculum.get 'Disposable.View'

    afterEach ->
      view.dispose()

    dependsMixins Oraculum, 'Disposable.Mixin',
      'Evented.Mixin'
      'Freezable.Mixin'

    it 'should trigger dispose:before, dispose, dispose:after', ->
      view.on 'dispose:before', beforeSpy = sinon.spy()
      view.on 'dispose', duringSpy = sinon.spy()
      view.on 'dispose:after', afterSpy = sinon.spy()
      view.dispose()
      expect(beforeSpy).toHaveBeenCalledWith view
      expect(duringSpy).toHaveBeenCalledWith view
      expect(afterSpy).toHaveBeenCalledWith view
      view.dispose()
      expect(beforeSpy).toHaveBeenCalledOnce()
      expect(duringSpy).toHaveBeenCalledOnce()
      expect(afterSpy).toHaveBeenCalledOnce()

    it 'should set view.disposed to true before trigger dispose:after', ->
      view.on 'dispose:before', -> expect(view.disposed).not.toBeTrue()
      view.on 'dispose', -> expect(view.disposed).not.toBeTrue()
      view.on 'dispose:after', -> expect(view.disposed).toBeTrue()
      view.dispose()

    it 'should remove all event listeners', ->
      view.on 'onSpy', onSpy = sinon.spy()
      view.listenTo view, 'listenSpy', listenSpy = sinon.spy()
      view.trigger 'onSpy'
      view.trigger 'listenSpy'
      view.dispose()
      view.trigger 'onSpy'
      view.trigger 'listenSpy'
      expect(onSpy).toHaveBeenCalledOnce()
      expect(listenSpy).toHaveBeenCalledOnce()

    it 'should delete all non-function object primitives', ->
      view.retainFunction = ->
      view.deleteObject = {}
      view.dispose()
      expect(view.retainFunction).toBeFunction()
      expect(view.deleteObject).toBeUndefined()

    it 'should invoke dispose on all objects that expose a dispose method if disposeAll is true', ->
      dispose = sinon.spy()
      view.mixinOptions.disposable.disposeAll = true
      view.disposeableObject = {dispose}
      view.nonDisposeableObject = {'dispose'}
      expect(-> view.dispose()).not.toThrow()
      expect(dispose).toHaveBeenCalledOnce()

    it 'should freeze the object', ->
      view.dispose()
      try view.someProp = 'test'
      expect(view.someProp).toBeUndefined()
      expect(Object.isFrozen view).toBeTrue()

    it 'should dispose of the object from the factory', ->
      view.dispose()
      expect(Oraculum.verifyTags view).toBeFalse()
