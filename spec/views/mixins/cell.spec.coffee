define [
  'oraculum'
  'oraculum/libs'
  'fastTable/views/mixins/cell'
], (Oraculum) ->
  'use strict'

  $ = Oraculum.get 'jQuery'

  describe 'Cell.TemplateMixin', ->

    column = null
    $template = null

    beforeEach ->
      column = Oraculum.get 'Model', {'attribute'}
      $template = $('<div/>').data({column})
      Oraculum.applyMixin $template, 'Cell.TemplateMixin'

    it 'should add the "cell" className', ->
      expect($template).toHaveClass 'cell'

    it 'should add the "cell-mixin" className', ->
      expect($template).toHaveClass 'cell-template-mixin'

    it 'should add an attribute className', ->
      expect($template).toHaveClass 'attribute-cell'
