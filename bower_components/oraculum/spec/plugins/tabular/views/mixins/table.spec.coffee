require [
  'oraculum'
  'oraculum/mixins/disposable'
  'oraculum/models/mixins/disposable'
  'oraculum/plugins/tabular/views/mixins/table'
], (Oraculum) ->
  'use strict'

  describe 'Table.ViewMixin', ->

    Oraculum.extend 'Collection', 'Disposable.Table.ViewMixin.Test.Collection', {
    }, mixins: ['Disposable.CollectionMixin']

    Oraculum.extend 'View', 'Table.ViewMixin.Test.View', {
      mixinOptions:
        disposable:
          disposeAll: true
    }, mixins: [
      'Disposable.Mixin'
      'Table.ViewMixin'
    ]

    columns = null
    testView = null
    collection = null

    beforeEach ->
      columns = Oraculum.get 'Disposable.Table.ViewMixin.Test.Collection'
      collection = Oraculum.get 'Disposable.Table.ViewMixin.Test.Collection'
      testView = Oraculum.get 'Table.ViewMixin.Test.View', {columns, collection}

    afterEach ->
      testView.dispose()

    it 'should allow columns to be passed via the constructor', ->
      expect(testView.columns).toBe columns
      expect(testView.mixinOptions.table.columns).toBe columns

    it 'should allow columns to be a definition name', ->
      testView.dispose()
      columns = 'Disposable.Table.ViewMixin.Test.Collection'
      collection = 'Disposable.Table.ViewMixin.Test.Collection'
      testView = Oraculum.get 'Table.ViewMixin.Test.View', {columns, collection}
      expect(testView.columns).toBeInstanceOf Oraculum.getConstructor columns

    it 'should extend list.viewOptions and set collection: columns', ->
      viewOptions = testView.mixinOptions.list.viewOptions
      expect(viewOptions.collection).toBe columns

    it 'should modify list.viewOptions to set collection: columns if list.viewOptions is a function', ->
      testView.dispose()
      viewOptions = -> {'test'}
      columns = Oraculum.get 'Disposable.Table.ViewMixin.Test.Collection'
      collection = Oraculum.get 'Disposable.Table.ViewMixin.Test.Collection'
      testView = Oraculum.get 'Table.ViewMixin.Test.View', {columns, collection, viewOptions}
      viewOptions = testView.mixinOptions.list.viewOptions
      expect(viewOptions).toBeFunction()
      result = viewOptions.call testView
      expect(result).toEqual {'test', collection: columns}
