define [
  'oraculum'
  'oraculum/libs'
  'fastTable/views/mixins/sortable-cell'
], (Oraculum) ->
  'use strict'

  $ = Oraculum.get 'jQuery'

  describe 'Sortable.CellTemplateMixin', ->

    column = null

    beforeEach ->
      column = Oraculum.get 'Model', {'attribute'}

    it 'should add the "sortable-cell-template-mixin" className', ->
      $template = $('<div/>').data({column})
      Oraculum.applyMixin $template, 'Sortable.CellTemplateMixin'
      expect($template).toHaveClass 'sortable-cell-template-mixin'

    it 'should add the "sortable" className based on the columns sortable attribute', ->
      column.set sortable: true
      $template = $('<div/>').data({column})
      Oraculum.applyMixin $template, 'Sortable.CellTemplateMixin'
      expect($template).toHaveClass 'sortable'

    it 'should not add the "sortable" className based on the columns sortable attribute', ->
      column.set sortable: false
      $template = $('<div/>').data({column})
      Oraculum.applyMixin $template, 'Sortable.CellTemplateMixin'
      expect($template).not.toHaveClass 'sortable'

    it 'should add the "sorted" className based on the columns sortDirection attribute', ->
      column.set sortDirection: 'someDirection'
      $template = $('<div/>').data({column})
      Oraculum.applyMixin $template, 'Sortable.CellTemplateMixin'
      expect($template).toHaveClass 'sorted'

    it 'should not add the "sorted" className based on the columns sortDirection attribute', ->
      $template = $('<div/>').data({column})
      Oraculum.applyMixin $template, 'Sortable.CellTemplateMixin'
      expect($template).not.toHaveClass 'sorted'

    it 'should add the proper directional className based on the columns sortDirection attribute', ->
      column.set sortDirection: 1
      $template = $('<div/>').data({column})
      Oraculum.applyMixin $template, 'Sortable.CellTemplateMixin'
      expect($template).toHaveClass 'descending'

      column.set sortDirection: -1
      $template = $('<div/>').data({column})
      Oraculum.applyMixin $template, 'Sortable.CellTemplateMixin'
      expect($template).toHaveClass 'ascending'
