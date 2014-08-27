define [
  'oraculum'
  'oraculum/libs'
  'fastTable/views/mixins/hideable-cell'
], (Oraculum) ->
  'use strict'

  $ = Oraculum.get 'jQuery'

  describe 'Hideable.CellTemplateMixin', ->

    column = null

    beforeEach ->
      column = Oraculum.get 'Model', {'attribute'}

    it 'should add the "hideable-cell-template-mixin" className', ->
      $template = $('<div/>').data({column})
      Oraculum.applyMixin $template, 'Hideable.CellTemplateMixin'
      expect($template).toHaveClass 'hideable-cell-template-mixin'

    it 'should be visible based on the columns hidden attribute', ->
      $template = $('<div/>').data({column})
      Oraculum.applyMixin $template, 'Hideable.CellTemplateMixin'
      $template.appendTo document.body
      expect($template).toBeVisible()
      $template.remove()

    it 'should not be visible based on the columns hidden attribute', ->
      column.set hidden: true
      $template = $('<div/>').data({column})
      Oraculum.applyMixin $template, 'Hideable.CellTemplateMixin'
      $template.appendTo document.body
      expect($template).not.toBeVisible()
      $template.remove()
