require [
  'oraculum'
  'oraculum/plugins/tabular/views/cells/checkbox'
], (Oraculum) ->
  'use strict'

  describe 'Checkbox.Cell', ->
    definition = Oraculum.definitions['Checkbox.Cell']
    ctor = definition.constructor

    view = null
    model = null
    column = null

    beforeEach ->
      model = Oraculum.get 'Model',
        attribute1: true
        attribute2: null
      column = Oraculum.get 'Model', {attribute: 'attribute1'}
      view = Oraculum.get 'Checkbox.Cell', {model, column}

    afterEach ->
      view.mixinOptions.disposable.disposeAll = true
      view.dispose()

    containsMixins definition,
      'Cell.ViewMixin'
      'Listener.Mixin'
      'Disposable.Mixin'
      'EventedMethod.Mixin'
      'HTMLTemplating.ViewMixin'

    it 'should render a checkbox element', ->
      view.render()
      expect(view.$el).toContain 'input[type="checkbox"]'

    it 'should set the checkboxes checked state based on the models target attribute', ->
      view.render()
      expect(view.$el).toContain 'input:checked'
      model.set 'attribute1', false
      expect(view.$el).not.toContain 'input:checked'

    it 'should set the models target attribute based on the checkboxes checked state', ->
      view.render()
      expect(model.get 'attribute1').toBeTrue()
      view.$('input[type="checkbox"]').prop('checked', false).change()
      expect(model.get 'attribute1').toBeFalse()
      view.$('input[type="checkbox"]').prop('checked', true).change()
      expect(model.get 'attribute1').toBeTrue()

    it 'should continue to function if the columns attribute changes', ->
      view.render()
      expect(view.$el).toContain 'input:checked'
      column.set 'attribute', 'attribute2'
      expect(view.$el).not.toContain 'input:checked'
      model.set 'attribute2', true
      expect(view.$el).toContain 'input:checked'
      view.$('input[type="checkbox"]').prop('checked', false).change()
      expect(model.get 'attribute2').toBeFalse()

