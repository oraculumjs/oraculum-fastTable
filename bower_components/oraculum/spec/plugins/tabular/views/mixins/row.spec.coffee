require [
  'oraculum'
  'oraculum/mixins/disposable'
  'oraculum/models/mixins/disposable'
  'oraculum/plugins/tabular/views/mixins/row'
], (Oraculum) ->
  'use strict'

  describe 'Row.ViewMixin', ->

    Oraculum.extend 'Collection', 'Disposable.Row.ViewMixin.Test.Collection', {
    }, mixins: ['Disposable.CollectionMixin']

    Oraculum.extend 'Model', 'Disposable.Row.ViewMixin.Test.Model', {
    }, mixins: ['Disposable.Mixin']

    Oraculum.extend 'View', 'Row.ViewMixin.Test.View', {
      mixinOptions:
        list:
          modelView: null
        disposable:
          disposeAll: true
    }, mixins: [
      'Disposable.Mixin'
      'Row.ViewMixin'
    ]

    model = null
    testView = null
    collection = null

    createView = null
    insertView = null

    beforeEach ->
      model = Oraculum.get 'Disposable.Row.ViewMixin.Test.Model', {'attribute'}
      collection = Oraculum.get 'Disposable.Row.ViewMixin.Test.Collection'
      testView = Oraculum.get 'Row.ViewMixin.Test.View', {model, collection}
      createView = sinon.stub(testView, 'createView').returns render: ->
      insertView = sinon.stub(testView, 'insertView')

    afterEach ->
      testView.dispose()

    it 'should allow modelView to be set on the column', ->
      collection.add { 'attribute', modelView: 'Test.View' }
      expect(createView).toHaveBeenCalledOnce()
      expect(createView.firstCall.args[0]).toImplement view: 'Test.View'

    it 'should allow viewOptions to be set on the column', ->
      collection.add { 'attribute', modelView: 'Test.View', viewOptions: {'test'} }
      expect(createView).toHaveBeenCalledOnce()
      expect(createView.firstCall.args[0].viewOptions).toImplement {'test'}

    it 'should allow the configured viewOptions to be a function', ->
      testView.mixinOptions.list.viewOptions = -> {'test'}
      collection.add { 'attribute', modelView: 'Test.View'}
      expect(createView).toHaveBeenCalledOnce()
      expect(createView.firstCall.args[0].viewOptions).toImplement {'test'}

    it 'should always pass the column in the viewOptions', ->
      collection.add { 'attribute', modelView: 'Test.View', viewOptions: {'test'} }
      expect(createView).toHaveBeenCalledOnce()
      expect(createView.firstCall.args[0].viewOptions).toImplement
        column: collection.models[0]

    it 'should pass the column as model if no model is present', ->
      delete testView.model
      collection.add { 'attribute', modelView: 'Test.View', viewOptions: {'test'} }
      expect(createView.firstCall.args[0].viewOptions).toImplement
        model: collection.models[0]

    it 'should throw if no modelView is configured', ->
      epicFail = -> collection.add {'attribute'}
      expect(epicFail).toThrow()
