define [
  'oraculum'
  'oraculum/libs'
  'fastTable/views/mixins/variable-width-cell'
], (Oraculum) ->
  'use strict'

  $ = Oraculum.get 'jQuery'

  describe 'VariableWidth.CellTemplateMixin', ->

    column = null

    beforeEach ->
      column = Oraculum.get 'Model', {'attribute'}

    it 'should add the "variable-width-cell-template-mixin" className', ->
      $template = $('<div/>').data({column})
      Oraculum.handleMixins $template, ['VariableWidth.CellTemplateMixin']
      expect($template).toHaveClass 'variable-width-cell-template-mixin'

    it 'should update its width based on the columns width attribute', ->
      column.set width: 100
      $template = $('<div/>').data({column})
      $template.appendTo document.body
      Oraculum.handleMixins $template, ['VariableWidth.CellTemplateMixin']
      expect($template.outerWidth()).toBe 100
      column.set width: 200
      expect($template.outerWidth()).toBe 200
