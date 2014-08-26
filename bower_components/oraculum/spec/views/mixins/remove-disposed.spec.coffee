require [
  'oraculum'
  'oraculum/mixins/disposable'
  'oraculum/views/mixins/remove-disposed'
], (Oraculum) ->
  'use strict'

  describe 'RemoveDisposed.ViewMixin', ->
    view = null
    remove = sinon.stub()

    Oraculum.extend 'View', 'RemoveDisposed.View', {
      mixinOptions:
        disposable:
          keepElement: 'truthyValue'
      remove: remove
    }, mixins: [
      'Disposable.Mixin'
      'RemoveDisposed.ViewMixin'
    ]

    dependsMixins Oraculum, 'RemoveDisposed.ViewMixin',
      'Evented.Mixin'

    it 'should read keepElement at construction', ->
      view = Oraculum.get 'RemoveDisposed.View'
      expect(view.mixinOptions.disposable.keepElement).toBe 'truthyValue'
      view.dispose()
      expect(remove).toHaveBeenCalledOnce()

      view = Oraculum.get 'RemoveDisposed.View', keepElement: false
      expect(view.mixinOptions.disposable.keepElement).toBe false
      view.dispose()
      expect(remove).toHaveBeenCalledTwice()

      view = Oraculum.get 'RemoveDisposed.View', keepElement: true
      expect(view.mixinOptions.disposable.keepElement).toBe true
      view.dispose()
      expect(remove).toHaveBeenCalledTwice()

