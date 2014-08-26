require [
  'oraculum'
  'oraculum/plugins/tabular/views/cells/header'
], (Oraculum) ->
  'use strict'

  describe 'Header.Cell', ->
    definition = Oraculum.definitions['Header.Cell']
    ctor = definition.constructor

    view = null
    model = column = null

    beforeEach ->
      model = column = Oraculum.get 'Model',
        label: 'Some Label'
        sortable: true
        attribute: 'attribute1'
      view = Oraculum.get 'Header.Cell', {model, column}

    afterEach ->
      view.mixinOptions.disposable.disposeAll = true
      view.dispose()

    containsMixins definition,
      'Listener.Mixin'
      'Disposable.Mixin'
      'EventedMethod.Mixin'
      'Cell.ViewMixin'
      'HTMLTemplating.ViewMixin'

    it 'should render an anchor with the models label or attribute', ->
      view.render()
      expect(view.el).toContain 'a'
      anchor = view.$ 'a'
      expect(anchor.text()).toBe 'Some Label'
      column.unset 'label'
      expect(anchor.text()).toBe 'attribute1'

    it 'should toggle the anchors "disabled" css class based on the columns sortable attribute', ->
      view.render()
      anchor = view.$ 'a'
      expect(anchor).not.toHaveClass 'disabled'
      column.set 'sortable', false
      expect(anchor).toHaveClass 'disabled'

    it 'should update the views css class to represent its sort direction', ->
      view.render()
      expect(view.el).not.toHaveClass 'ascending'
      expect(view.el).not.toHaveClass 'descending'
      column.set 'sortDirection', -1
      expect(view.el).toHaveClass 'ascending'
      expect(view.el).not.toHaveClass 'descending'
      column.set 'sortDirection', 1
      expect(view.el).not.toHaveClass 'ascending'
      expect(view.el).toHaveClass 'descending'
      column.unset 'sortDirection'
      expect(view.el).not.toHaveClass 'ascending'
      expect(view.el).not.toHaveClass 'descending'

    it 'should respond to anchor clicks if the columns is sortable', ->
      view.render()
      stub = column.nextDirection = sinon.stub()
      anchor = view.$ 'a'
      anchor.click()
      expect(stub).toHaveBeenCalledOnce()
      column.set 'sortable', false
      anchor.click()
      expect(stub).toHaveBeenCalledOnce()

