require [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/disposable'
  'oraculum/views/mixins/list'
  'oraculum/views/mixins/auto-render'
  'oraculum/views/mixins/html-templating'
], (Oraculum) ->
  'use strict'

  $ = Oraculum.get 'jQuery'
  _ = Oraculum.get 'underscore'

  describe 'CollectionView', ->
    mixin = Oraculum.mixins['List.ViewMixin']
    collection = null
    listView = null

    Oraculum.extend 'View', 'ListItem.View', {
      tagName: 'li'
      initialize: ->
        @el.setAttribute 'id', @model.id
        @el.setAttribute 'cid', @model.cid
      render: ->
        @$el.text @model.get('title') or 'none'
        return this
    }, mixins: ['Disposable.Mixin']

    Oraculum.extend 'View', 'List.View', {
      tagName: 'ul'
      mixinOptions:
        list:
          modelView: 'ListItem.View'
    }, mixins: [
      'List.ViewMixin'
      'AutoRender.ViewMixin'
    ]

    hasOwnProp = (object, prop) ->
      Object::hasOwnProperty.call object, prop

    # Create 26 objects with IDs A-Z and a random title
    freshModels = ->
      for code in [65..90] # A-Z
        {
          id: String.fromCharCode(code)
          title: String(Math.random())
        }

    oneModel = ->
      Oraculum.get 'Model',
        id: 'one'
        title: 'one'

    # Add one model with id: one and return it
    addOne = ->
      model = oneModel()
      collection.add model
      return model

    threeModels = ->
      model1 = Oraculum.get 'Model', id: 'new1', title: 'new'
      model2 = Oraculum.get 'Model', id: 'new2', title: 'new'
      model3 = Oraculum.get 'Model', id: 'new3', title: 'new'
      return [model1, model2, model3]

    # Add three models with id: new1-3 and return an array containing them
    addThree = ->
      models = threeModels()
      collection.add models[0], at: 0
      collection.add models[1], at: 10
      collection.add models[2]
      return models

    viewsMatchCollection = ->
      children = listView._$list.children listView.mixinOptions.list.viewSelector
      expect(children.length).toBe collection.length
      collection.forEach (model, index) ->
        el = children[index]

        expectedId = String model.id
        actualId = el.id
        expect(actualId).toBe expectedId

        expectedTitle = model.get('title')
        if expectedTitle?
          actualTitle = el.textContent
          expect(actualTitle).toBe expectedTitle

    createCollection = (models) ->
      models or= freshModels()
      collection = Oraculum.get 'Collection', models

    createCollectionView = ->
      listView = Oraculum.get 'List.View', {collection}

    basicSetup = (models) ->
      createCollection models
      listView = Oraculum.get 'List.View', {collection}

    afterEach ->
      listView?.__dispose()
      collection?.__dispose()

    describe 'Basic item rendering', ->

      it 'should render item views', ->
        basicSetup()
        viewsMatchCollection()

      it 'should call a custom initModelView method', ->
        extend = { initModelView: (model) -> Oraculum.get 'ListItem.View', {model} }
        initModelView = sinon.spy extend, 'initModelView'
        Oraculum.extend 'List.View', 'CustomList.View', extend,
          override: true
          inheritMixins: true

        createCollection()
        listView = Oraculum.get 'CustomList.View', {collection}
        viewsMatchCollection()
        expect(initModelView.callCount).toBe collection.length

      it 'should respect the autoRender and renderItems options', ->
        createCollection()
        render = sinon.stub()
        renderAllModels = sinon.stub()
        Oraculum.extend 'List.View', 'CustomList.View', {render, renderAllModels},
          override: true
          inheritMixins: true

        listView = Oraculum.get 'CustomList.View', {
          collection,
          autoRender: false
          renderItems: false
        }

        expect(render).not.toHaveBeenCalled()
        expect(renderAllModels).not.toHaveBeenCalled()

        children = listView.$el.children()
        expect(children.length).toBe 0
        expect(hasOwnProp listView, '$list').toBeFalse()

        listView.render()
        expect(listView._$list).toBeInstanceOf $
        expect(listView._$list.length).toBe 1

        listView.renderAllModels()
        viewsMatchCollection()

    describe 'Basic collection change behavior', ->

      it 'should add views when collection items are added', ->
        basicSetup()
        addThree()
        viewsMatchCollection()

      it 'should remove views when collection items are removed', ->
        basicSetup()
        models = addThree()
        collection.remove models
        viewsMatchCollection()

      it 'should remove all views when collection is emptied', ->
        basicSetup()
        collection.reset()
        children = listView._$list.children listView.mixinOptions.list.viewSelector
        expect(children.length).toBe 0

    describe 'Sorting', ->

      it 'should reorder views on sort', ->
        basicSetup threeModels()

        sortAndMatch = (comparator) ->
          collection.comparator = comparator
          collection.sort()
          viewsMatchCollection()

        # Explicity force a default sort to ensure two different sort orderings
        sortAndMatch (a, b) -> a.id > b.id

        # Reverse the sort order and test it
        sortAndMatch (a, b) -> a.id < b.id

    describe 'Complex Reset and Set behavior', ->

      it 'should reuse views on reset', ->
        basicSetup()
        expect(listView.getModelViews()).toBeObject()

        model1 = collection.at 0
        view1 = listView.subview "modelView:#{model1.cid}"
        expect(view1.__type()).toBe 'ListItem.View'

        model2 = collection.at 1
        view2 = listView.subview "modelView:#{model2.cid}"
        expect(view2.__type()).toBe 'ListItem.View'

        collection.reset model1

        expect(view1.disposed).toBeUndefined()
        expect(view2.disposed).toBeTrue()

        newView1 = listView.subview "modelView:#{model1.cid}"
        expect(newView1).toBe view1

      it 'should insert views in the right order on reset', ->
        basicSetup()

        m0 = Oraculum.get 'Model', id: 0
        m1 = Oraculum.get 'Model', id: 1
        m2 = Oraculum.get 'Model', id: 2
        m3 = Oraculum.get 'Model', id: 3
        m4 = Oraculum.get 'Model', id: 4
        m5 = Oraculum.get 'Model', id: 5

        baseResetAndCheck = (models1, models2) ->
          collection.reset models1
          collection.reset models2
          viewsMatchCollection()

        makeResetAndCheck = (models1) -> (models2) ->
          baseResetAndCheck models1, models2

        full = [m0, m1, m2, m3, m4, m5]

        # Removal tests from a full collection

        resetAndCheck = makeResetAndCheck full
        # Remove first
        resetAndCheck [m1, m2, m3, m4, m5]
        # Remove last
        resetAndCheck [m0, m1, m2, m3, m4]
        # Remove two in the middle
        resetAndCheck [m0, m1, m4, m5]
        # Remove every first
        resetAndCheck [m1, m3, m5]
        # Remove every second
        resetAndCheck [m0, m2, m4]

        # Addition tests

        resetAndCheck = makeResetAndCheck [m1, m2, m3]
        # Add at the beginning
        resetAndCheck [m0, m1, m2, m3]
        # Add at the end
        resetAndCheck [m1, m2, m3, m4]
        # Add two in the middle
        baseResetAndCheck [m0, m1, m4, m5], full
        # Add every first
        baseResetAndCheck [m1, m3, m5], full
        # Add every second
        baseResetAndCheck [m0, m2, m4], full

        # Addition and removal tests

        # Replace first
        baseResetAndCheck [m0, m2, m3], [m1, m2, m3]
        # Replace last
        baseResetAndCheck [m0, m2, m5], [m0, m3, m5]
        # Replace in the middle
        baseResetAndCheck [m0, m2, m5], [m0, m3, m5]
        # Change two in the middle
        baseResetAndCheck [m0, m2, m3, m5], [m0, m3, m4, m5]
        # Flip two in the middle
        baseResetAndCheck [m0, m1, m2, m3], [m0, m2, m1, m3]
        # Complete replacement
        baseResetAndCheck [m0, m1, m2], [m3, m4, m5]

      it 'should insert views in the right order on set', ->
        basicSetup()

        m0 = Oraculum.get 'Model', id: 0
        m1 = Oraculum.get 'Model', id: 1
        m2 = Oraculum.get 'Model', id: 2
        m3 = Oraculum.get 'Model', id: 3
        m4 = Oraculum.get 'Model', id: 4
        m5 = Oraculum.get 'Model', id: 5

        baseSetAndCheck = (models1, models2) ->
          collection.reset models1
          collection.set models2
          viewsMatchCollection()

        makeSetAndCheck = (setup) -> (models) ->
          baseSetAndCheck setup, models

        full = [m0, m1, m2, m3, m4, m5]

        # Removal tests from a full collection

        setAndCheck = makeSetAndCheck full
        # Remove first
        setAndCheck [m1, m2, m3, m4, m5]
        # Remove last
        setAndCheck [m0, m1, m2, m3, m4]
        # Remove two in the middle
        setAndCheck [m0, m1, m4, m5]
        # Remove every first
        setAndCheck [m1, m3, m5]
        # Remove every second
        setAndCheck [m0, m2, m4]

        # Addition tests

        setAndCheck = makeSetAndCheck [m1, m2, m3]
        # Add at the beginning
        setAndCheck [m0, m1, m2, m3]
        # Add at the end
        setAndCheck [m1, m2, m3, m4]
        # Add two in the middle
        baseSetAndCheck [m0, m1, m4, m5], full
        # Add every first
        baseSetAndCheck [m1, m3, m5], full
        # Add every second
        baseSetAndCheck [m0, m2, m4], full

        # Addition and removal tests

        # Replace first
        baseSetAndCheck [m0, m2, m3], [m1, m2, m3]
        # Replace last
        baseSetAndCheck [m0, m2, m5], [m0, m3, m5]
        # Replace in the middle
        baseSetAndCheck [m0, m2, m5], [m0, m3, m5]
        # Change two in the middle
        baseSetAndCheck [m0, m2, m3, m5], [m0, m3, m4, m5]
        # Flip two in the middle
        baseSetAndCheck [m0, m1, m2, m3], [m0, m2, m1, m3]
        # Complete replacement
        baseSetAndCheck [m0, m1, m2], [m3, m4, m5]

    describe 'Visible items', ->

      it 'should have a visibleModels array', ->
        basicSetup()
        visibleModels = listView.visibleModels
        expect(visibleModels).toBeArray()
        expect(visibleModels.length).toBe collection.length
        collection.forEach (model, index) ->
          expect(visibleModels[index]).toBe model

      it 'should fire visibilityChange events', ->
        basicSetup []
        visibilityChange = sinon.spy()
        listView.on 'visibilityChange', visibilityChange
        addOne()
        expect(visibilityChange).toHaveBeenCalledWith listView.visibleModels
        expect(listView.visibleModels.length).toBe 1

    describe 'Filtering', ->

      it 'should filter views using the filterer', ->
        basicSetup()
        filterer = sinon.spy (model, position) ->
          expect(model.__tags()).toContain 'Model'
          expect(this).toBe listView
          expect(position).toBeNumber()
          return true
        listView.filter filterer
        expect(filterer.callCount).toBe collection.length

      it 'should not set filterer to non-function', ->
        basicSetup()
        filterer = listView.mixinOptions.list.filterer = sinon.spy -> true
        listView.filter()
        expect(filterer.callCount).toBe collection.length

      it 'should hide filtered views per default', ->
        basicSetup()
        addThree()

        listView.filter (model) -> model.get('title') is 'new'

        children = listView._$list.children listView.mixinOptions.list.viewSelector
        collection.forEach (model, index) ->
          el = children[index]
          displayValue = el.style.display
          if model.get('title') is 'new'
          then expect(displayValue).toBe ''
          else expect(displayValue).toBe 'none'

      it 'should respect the filterer option', ->
        createCollection()

        filterer = (model) -> model.id is 'A'
        listView = Oraculum.get 'List.View', { collection, filterer }

        expect(listView.mixinOptions.list.filterer).toBe filterer
        expect(listView.visibleModels.length).toBe 1

        children = listView._$list.children listView.mixinOptions.list.viewSelector
        expect(children.length).toBe collection.length

      it 'should remove the filter', ->
        basicSetup()
        addThree()

        listView.filter (model) -> model.get('title') is 'new'
        listView.filter null

        children = listView._$list.children listView.mixinOptions.list.viewSelector
        for element in children
          displayValue = $(element).css 'display'
          expect(displayValue).not.toBe 'none'

        expect(listView.visibleModels.length).toBe collection.length

      it 'should save the filterer', ->
        basicSetup()

        filterer = -> false
        listView.filter filterer
        expect(listView.mixinOptions.list.filterer).toBe filterer

        listView.filter null
        expect(listView.mixinOptions.list.filterer).toBe null

      it 'should trigger visibilityChange and update visibleModels', ->
        basicSetup()
        addThree()
        expect(listView.visibleModels.length).toBe collection.length

        visibilityChange = sinon.spy()
        listView.on 'visibilityChange', visibilityChange
        listView.filter (model) -> model.get('title') is 'new'

        expect(visibilityChange).toHaveBeenCalledOnce()
        args = visibilityChange.firstCall.args
        expect(args.length).toBe 1
        expect(args[0]).toBe listView.visibleModels
        expect(listView.visibleModels.length).toBe 3

        # Remove filter again
        listView.filter null
        expect(listView.visibleModels.length).toBe collection.length

    describe 'Filter callback', ->

      it 'should filter views with a callback', ->
        basicSetup()

        filterer = (model) -> model.get('title') is 'new'
        filterCallback = (view, included) ->
          cls = if included then 'included' else 'not-included'
          view.$el.addClass cls

        filterCallbackSpy = sinon.spy filterCallback
        listView.filter filterer, filterCallbackSpy

        expect(filterCallbackSpy.callCount).toBe collection.length

        checkCall = (model, call) ->
          view = listView.subview "modelView:#{model.cid}"
          included = filterer model
          expect(call).toHaveBeenCalledWith view, included
          hasClass = view.el.className.indexOf(
            if included then 'included' else 'not-included'
          ) isnt -1
          expect(hasClass).toBeTrue()

        collection.forEach (model, index) ->
          call = filterCallbackSpy.getCall index
          checkCall model, call

        models = addThree()
        expect(filterCallbackSpy.callCount).toBe collection.length
        startIndex = 26
        for model, index in models
          call = filterCallbackSpy.getCall startIndex + index
          checkCall model, call

      it 'should save the filter callback', ->
        basicSetup()

        _filterCallback = mixin.mixinOptions.list.filterCallback
        filterer = -> false
        filterCallback = ->
        expect(listView.mixinOptions.list.filterCallback).toBe _filterCallback
        listView.filter filterer, filterCallback
        expect(listView.mixinOptions.list.filterCallback).toBe filterCallback

      it 'should not call the filter callback when unfiltered', ->
        createCollection []
        listView = Oraculum.get 'List.View', {collection}

        spy = sinon.spy listView.mixinOptions.list, 'filterCallback'
        collection.reset freshModels()
        addThree()
        expect(spy).not.toHaveBeenCalled()
        spy.restore()

    describe 'Templated CollectionView', ->

      Oraculum.extend 'View', 'TemplatedList.View', {
        mixinOptions:
          list:
            modelView: 'ListItem.View'
            listSelector: 'ol'
          template: '''
            <div class="unrelated">
            <ol/>
          '''

      }, mixins: [
        'List.ViewMixin'
        'Disposable.Mixin'
        'HTMLTemplating.ViewMixin'
        'AutoRender.ViewMixin'
      ]

      beforeEach ->
        createCollection()
        listView = Oraculum.get 'TemplatedList.View', {collection}

      it 'should retain templated nodes', ->
        expect(listView.el).toContain '.unrelated'
        collection.reset()
        expect(listView.el).toContain '.unrelated'

      it 'should retain subviews that don\'t belong to the list', ->
        subview = listView.createSubview 'testView', {view: 'View'}
        expect(listView._subviews).toContain subview
        collection.reset()
        expect(listView._subviews).toContain subview

      describe 'Selectors', ->

        it 'should append views to the listSelector', ->
          expect(listView._$list).toBeInstanceOf $
          expect(listView._$list.length).toBe 1

          $list2 = listView.$(listView.mixinOptions.list.listSelector)
          expect(listView._$list.get(0)).toBe $list2.get(0)

          children = listView._$list.children listView.mixinOptions.list.viewSelector
          expect(children.length).toBe collection.length

        it 'should respect the itemSelector property', ->
          Oraculum.extend 'View', 'MixedTemplatedList.View', {
            mixinOptions:
              list:
                modelView: 'ListItem.View'
                viewSelector: 'li'
              template: '''
                <p>foo</p>
                <div>bar</div>
                <article>qux</article>
                <ul>
                <li>nested</li>
                </ul>
              '''

          }, mixins: [
            'List.ViewMixin'
            'Disposable.Mixin'
            'HTMLTemplating.ViewMixin'
            'AutoRender.ViewMixin'
          ]

          listView.dispose()
          listView = Oraculum.get 'MixedTemplatedList.View', {collection}

          additionalLength = 4
          allChildren = listView.$el.children()
          expect(allChildren.length).toBe collection.length + additionalLength
          viewChildren = listView._$list.children listView.mixinOptions.list.viewSelector
          expect(viewChildren.length).toBe collection.length

          # The first element is not an item view
          expect(allChildren[0]).not.toBe viewChildren[0]
          # The item views are append after the existing elements
          expect(allChildren[additionalLength]).toBe viewChildren[0]
