define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/disposable'
  'oraculum/models/mixins/disposable'
  'fastTable/views/mixins/cell'
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
      testView = Oraculum.get 'FastRow.Test.View',
        model: model
        collection: collection

    afterEach ->
      testView.dispose()

    describe 'reactionary behavior', ->
      render = null

      beforeEach ->
        render = sinon.stub testView, 'render'

      afterEach ->
        render.restore()

      it 'should debounce invoke render on all model events', ->
        model.trigger 'theresNoWayThisIsAnActualEvent'
        waits(10) or runs ->
          expect(render).toHaveBeenCalledOnce()

      it 'should debounce invoke render on all collection change events', ->
        collection.trigger 'change'
        waits(10) or runs ->
          expect(render).toHaveBeenCalledOnce()

      it 'should invoke render on collection add, remove, reset, sort', ->
        collection.trigger 'add'
        expect(render).toHaveBeenCalledOnce()
        render.reset()
        collection.trigger 'remove'
        expect(render).toHaveBeenCalledOnce()
        render.reset()
        collection.trigger 'reset'
        expect(render).toHaveBeenCalledOnce()
        render.reset()
        collection.trigger 'sort'
        expect(render).toHaveBeenCalledOnce()
        render.reset()

    describe 'render method', ->

      it 'should return this', ->
        expect(testView.render()).toBe testView

      it 'should throw if a column is missing a template', ->
        collection.add {'attribute'}, silent: true
        expect(-> testView.render()).toThrow()

      describe 'column template elements', ->

        it 'should render the provided template', ->
          template = '<div id="somethingThatCouldntPossiblyBeInTheDom"/>'
          collection.add {'attribute', template}, silent: true
          testView.render()
          expect(testView.el).toContainHtml template

        it 'should allow the template to be a function', ->
          _template = '<div id="somethingThatCouldntPossiblyBeInTheDom"/>'
          template = sinon.stub().returns _template
          collection.add {'attribute', template}, silent: true
          testView.render()
          expect(template).toHaveBeenCalledOnce()
          expect(template.firstCall.args[0]).toImplement {'model', 'column'}
          expect(testView.el).toContainHtml _template

        it 'should apply the model and column to the elements data attributes', ->
          collection.add {'attribute', template: '<div/>'}, silent: true
          testView.render()
          _.each testView.$el.children(), (element) ->
            expect($(element).data()).toImplement {'model', 'column'}

        it 'should apply any configured templateMixins to the element', ->
          collection.add {
            'attribute',
            template: '<div/>'
            templateMixins: ['FastRow.Test.TemplateMixin']
          }, silent: true
          testView.render()
          _.each testView.$el.children(), (element) ->
            expect(element).toHaveClass 'fast-row-test-template-mixin'
