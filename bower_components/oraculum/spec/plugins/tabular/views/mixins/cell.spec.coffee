require [
  'oraculum'
  'oraculum/plugins/tabular/views/mixins/cell'
], (Oraculum) ->
  'use strict'

  describe 'Cell.ViewMixin', ->
    view = null
    column = null

    Oraculum.extend 'View', 'Cell.View', {
      className: 'someClass'
    }, mixins: ['Cell.ViewMixin']

    beforeEach ->
      column = Oraculum.get 'Model', {'attribute'}
      column.isSorted = -> true
      view = Oraculum.get 'Cell.View', {column}
      view.$el.appendTo('body')

    afterEach ->
      view.__dispose()
      column.__dispose()

    dependsMixins Oraculum, 'Cell.ViewMixin',
      'Evented.Mixin'

    it 'should cache the column constructor arg', ->
      expect(view.column).toBe column

    it 'should add the appropriate css classes', ->
      expect(view.el).toHaveClass 'cell'
      expect(view.el).toHaveClass 'someClass'
      expect(view.el).toHaveClass 'attribute-cell'
      column.set 'attribute', 'anotherAttribute'
      expect(view.el).toHaveClass 'cell'
      expect(view.el).toHaveClass 'someClass'
      expect(view.el).toHaveClass 'anotherAttribute-cell'
      expect(view.el).not.toHaveClass 'attribute-cell'

    it 'should hide and show the cell', ->
      expect(view.el).toBeVisible()
      column.set 'hidden', true
      expect(view.el).not.toBeVisible()
      column.set 'hidden', false
      expect(view.el).toBeVisible()
