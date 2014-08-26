require [
  'oraculum'
  'oraculum/libs'
  'oraculum/models/mixins/disposable'
  'oraculum/models/mixins/pageable-interface'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  describe 'PageableInterface.CollectionMixin', ->
    collection = null

    Oraculum.extend 'Collection', 'PageableInterface.Collection', {
      model: 'Disposable.Model'
    }, mixins: [
      'Disposable.CollectionMixin'
      'PageableInterface.CollectionMixin'
    ]

    afterEach ->
      collection.dispose()

    describe 'construction & initialization', ->
      Oraculum.extend 'PageableInterface.Collection', 'ConfiguredPageableInterface.Collection', {
        mixinOptions: pageable: { from: 42, size: 42 * 2, start: 42 * 3 }
      }, inheritMixins: true

      it 'should create a `@pageState` `_PageableCollectionInterfaceState.Model`', ->
        collection = Oraculum.get 'PageableInterface.Collection'
        expect(collection.pageState.__type()).toBe '_PageableCollectionInterfaceState.Model'

      it 'should allow configuration of the `from`, `start`, and `size` options in `mixinOptions`', ->
        collection = Oraculum.get 'ConfiguredPageableInterface.Collection'
        expect(collection.pageState.get 'from').toBe 42
        expect(collection.pageState.get 'size').toBe 42 * 2
        expect(collection.pageState.get 'start').toBe 42 * 3

      it 'should allow configuration of the `from`, `start`, and `size` options at construction', ->
        collection = Oraculum.get 'PageableInterface.Collection', null, { from: 42, size: 42 * 2, start: 42 * 3 }
        expect(collection.pageState.get 'from').toBe 42
        expect(collection.pageState.get 'size').toBe 42 * 2
        expect(collection.pageState.get 'start').toBe 42 * 3

    describe 'memory management', ->

      it 'should dispose and delete `@pageState` on disposal', ->
        collection = Oraculum.get 'PageableInterface.Collection'
        pageState = collection.pageState
        pageStateDispose = sinon.spy pageState, 'dispose'
        collection.dispose()
        expect(pageStateDispose).toHaveBeenCalledOnce()
        expect(collection.pageState).not.toBeDefined()

    describe 'pagination interface', ->
      pageState = null

      beforeEach ->
        collection = Oraculum.get 'PageableInterface.Collection',
          from:  0
          size: 10
          start: 0
        pageState = collection.pageState

      describe '`hasPrevious` method', ->

        it 'should return true if there are previous pages, else return false', ->
          pageState.set 'total', 20
          expect(collection.hasPrevious()).toBeFalse()
          pageState.set 'page', 2
          expect(collection.hasPrevious()).toBeTrue()

      describe '`hasNext` method', ->

        it 'should return true if there are more pages, else return false', ->
          expect(collection.hasNext()).toBeFalse()
          pageState.set 'total', 100
          expect(collection.hasNext()).toBeTrue()
          pageState.set 'page', 10
          expect(collection.hasNext()).toBeFalse()

      describe '`previous` method', ->

        it 'should decrement the `page` attribute of `pageState` if `@hasPrevious()`', ->
          pageState.set 'page', 2
          expect(pageState.get 'page').toBe 2
          collection.previous()
          expect(pageState.get 'page').toBe 1
          collection.previous()
          expect(pageState.get 'page').toBe 1

      describe '`next` method', ->

        it 'should increment the `page` attribute of `pageState` if `@hasNext()`', ->
          collection.next()
          expect(pageState.get 'page').toBe 1
          pageState.set 'total', 100
          collection.next()
          expect(pageState.get 'page').toBe 2

      describe '`jumpTo` method', ->

        it 'should set the `page` attribute to the passed in `page` argument if that page is available', ->
          collection.jumpTo 0
          expect(pageState.get 'page').toBe 1
          collection.jumpTo 2
          expect(pageState.get 'page').toBe 1
          pageState.set 'total', 101
          collection.jumpTo 0
          expect(pageState.get 'page').toBe 1
          collection.jumpTo 10
          expect(pageState.get 'page').toBe 10

      describe '`jumpToFirst` method', ->

        it 'should jump to the first page', ->
          expect(pageState.get 'page').toBe 1
          pageState.set 'total', 101
          collection.jumpTo 5
          expect(pageState.get 'page').toBe 5
          collection.jumpToFirst()
          expect(pageState.get 'page').toBe 1

      describe '`jumpToLast` method', ->

        it 'should jump to the last page', ->
          expect(pageState.get 'page').toBe 1
          pageState.set 'start', 1
          pageState.set 'total', 100
          collection.jumpTo 5
          expect(pageState.get 'page').toBe 5
          collection.jumpToLast()
          expect(pageState.get 'page').toBe 10

      describe '`setPageSize` method', ->

        it 'should set the `size` attribute of `@pageState`', ->
          expect(pageState.get 'size').toBe 10
          collection.setPageSize 50
          expect(pageState.get 'size').toBe 50

      describe '`setPageStart` method', ->

        it 'should set the `start` attribute of `@pageState`', ->
          expect(pageState.get 'start').toBe 0
          collection.setPageStart 1
          expect(pageState.get 'start').toBe 1

  describe '`@pageState`', ->
    pageState = null

    beforeEach ->
      collection = Oraculum.get 'PageableInterface.Collection',
        from:  0
        size: 10
        start: 0
      pageState = collection.pageState

    describe 'automatic calculations', ->

      it 'should automatically calculate the `from` (offset) attribute', ->
        expect(pageState.get 'from').toBe 0
        pageState.set 'start', 1
        expect(pageState.get 'from').toBe 1
        pageState.set 'page', 2
        expect(pageState.get 'from').toBe 11

      it 'should automatically calculate the `page` attribute', ->
        expect(pageState.get 'page').toBe 1
        pageState.set 'from', 10
        expect(pageState.get 'page').toBe 2
        pageState.set 'from', 11
        expect(pageState.get 'page').toBe 2
        pageState.set 'size', 50
        expect(pageState.get 'page').toBe 2
        pageState.set 'from', 11
        expect(pageState.get 'page').toBe 1

      it 'should automatically calculate the `end` and `pages` attributes', ->
        expect(pageState.get 'end').toBe 0
        pageState.set 'start', 1
        expect(pageState.get 'end').toBe 1
        pageState.set 'total', 105
        expect(pageState.get 'end').toBe 106
        expect(pageState.get 'pages').toBe 11
        pageState.set 'start', 0
        expect(pageState.get 'end').toBe 105
        expect(pageState.get 'pages').toBe 11

    describe 'parser', ->

      it 'should `parseInt 10` any key present in `@defaults`', ->
        testResponse =
          from:  '1'
          size:  '2'
          start: '3'
          total: '4'
          end:   '5'
          page:  '6'
          pages: '7'
          other: '8'
        result = pageState.parse testResponse
        expect(result.from).toBe  1
        expect(result.size).toBe  2
        expect(result.start).toBe 3
        expect(result.total).toBe 4
        expect(result.end).toBe   5
        expect(result.page).toBe  6
        expect(result.pages).toBe 7
        expect(result.other).toBe '8'

      it 'should throw if any key present in `@defaults` is not a number', ->
        expect(-> pageState.parse from:  null).toThrow()
        expect(-> pageState.parse size:  undefined).toThrow()
        expect(-> pageState.parse start: new Date()).toThrow()
        expect(-> pageState.parse total: new Array()).toThrow()
        expect(-> pageState.parse end:   new Object()).toThrow()
        expect(-> pageState.parse page:  new RegExp()).toThrow()
        expect(-> pageState.parse pages: new Function()).toThrow()
