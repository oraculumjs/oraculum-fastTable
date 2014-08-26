require [
  'oraculum'
  'oraculum/plugins/tabular/views/cells/checkbox'
], (Oraculum) ->
  'use strict'

  describe 'Text.Cell', ->
    definition = Oraculum.definitions['Text.Cell']
    ctor = definition.constructor

    view = null
    model = null
    column = null

    beforeEach ->
      model = Oraculum.get 'Model',
        attribute1: true
        attribute2: null
      column = Oraculum.get 'Model', {attribute: 'attribute1'}
      view = Oraculum.get 'Text.Cell', {model, column}

    afterEach ->
      view.mixinOptions.disposable.disposeAll = true
      view.dispose()

    containsMixins definition,
      'Cell.ViewMixin'
      'Listener.Mixin'
      'Disposable.Mixin'
      'HTMLTemplating.ViewMixin'
      'DOMPropertyBinding.ViewMixin'

    it 'should render a property-bound element', ->
      view.render()
      expect(view.$el).toContain '[data-prop="model"][data-prop-attr="attribute1"]'

    it 'should update the property-bound element if the models target attribute changes', ->
      view.render()
      expect(view.$el).toContain '[data-prop="model"][data-prop-attr="attribute1"]'
      column.set 'attribute', 'attribute2'
      expect(view.$el).not.toContain '[data-prop="model"][data-prop-attr="attribute1"]'
      expect(view.$el).toContain '[data-prop="model"][data-prop-attr="attribute2"]'
