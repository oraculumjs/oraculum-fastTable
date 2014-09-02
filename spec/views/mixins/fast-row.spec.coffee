define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/disposable'
  'oraculum/models/mixins/disposable'
  'fastTable/views/mixins/fast-row'
], (Oraculum) ->
  'use strict'

  $ = Oraculum.get 'jQuery'
  _ = Oraculum.get 'underscore'

  describe 'FastRow.ViewMixin', ->

    Oraculum.extend 'Model', 'Disposable.FastRow.Test.Model', {
    }, mixins: ['Disposable.Mixin']

    Oraculum.extend 'Collection', 'Disposable.FastRow.Test.Collection', {
      model: 'Disposable.FastRow.Test.Model'
    }, mixins: ['Disposable.CollectionMixin']

    Oraculum.defineMixin 'FastRow.Test.TemplateMixin',
      mixinitialize: ->
        @addClass 'fast-row-test-template-mixin'

    Oraculum.extend 'View', 'FastRow.Test.View', {

      mixinOptions:
        disposable:
          disposeAll: true

    }, mixins: [
      'Disposable.Mixin'
      'FastRow.ViewMixin'
    ]

    model = null
    testView = null
    collection = null

    beforeEach ->
      model = Oraculum.get 'Disposable.FastRow.Test.Model', {'attribute'}
      collection = Oraculum.get 'Disposable.FastRow.Test.Collection'
      testView = Oraculum.get 'FastRow.Test.View', {model, collection}

    afterEach ->
      testView.dispose()

    it 'should throw if constructed without a collection', ->
      expect(-> Oraculum.get 'FastRow.Test.View').toThrow()

    describe 'mixin configuration', ->
      mixinSettings = Oraculum.mixinSettings['FastRow.ViewMixin']

      it 'should depend on List.ViewMixin', ->
        expect(mixinSettings.mixins).toContain 'List.ViewMixin'

    describe 'construction', ->

      it 'should delete list.modelView', ->
        expect(testView.mixinOptions.list.modelView).not.toBeDefined()

      it 'should allow defaultTemplate to be set at construction', ->
        defaultTemplate = '<div>defaultTemplate</div>'
        customView = Oraculum.get 'FastRow.Test.View', {model, collection, defaultTemplate}
        expect(customView.mixinOptions.list.defaultTemplate).toBe defaultTemplate
        customView.dispose()

    describe 'rendering behavior', ->

      it 'should render the defaultTemplate if no template is provided', ->
        defaultTemplate = sinon.spy testView.mixinOptions.list, 'defaultTemplate'
        collection.add {'attribute'}, silent: true
        testView.render()
        expect(defaultTemplate).toHaveBeenCalled()

      it 'should render the template provided by the column', ->
        template = '<div>columnTemplate</div>'
        collection.add {'attribute', template}, silent: true
        testView.render()
        expect(testView.el).toContainHtml template

      it 'should allow column.template to be a function', ->
        templateHTML = '<div>columnTemplate</div>'
        template = sinon.stub().returns templateHTML
        column = collection.add {'attribute', template}, silent: true
        testView.render()
        expect(testView.el).toContainHtml templateHTML
        expect(template).toHaveBeenCalledOnce()
        expect(template.firstCall.args[0]).toEqual {model, column}

      it 'should use column as model if no modal is present', ->
        model = testView.model
        delete testView.model
        templateHTML = '<div>columnTemplate</div>'
        template = sinon.stub().returns templateHTML
        column = collection.add {'attribute', template}, silent: true
        testView.render()
        expect(template).toHaveBeenCalledOnce()
        expect(template.firstCall.args[0]).toEqual {model: column, column}
        testView.model = model
