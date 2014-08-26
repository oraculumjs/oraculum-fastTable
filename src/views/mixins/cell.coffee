define [
  'oraculum'
  'fastTable/views/mixins/hideable-cell'
  'fastTable/views/mixins/sortable-cell'
], (Oraculum) ->
  'use strict'

  Oraculum.defineMixin 'Cell.TemplateMixin', {

    mixinitialize: ->
      attribute = @data('column').get 'attribute'
      @addClass 'cell'
      @addClass 'cell-mixin'
      @addClass "#{attribute}-cell".replace /[\.\s]/, '-'

  }, mixins: [
    'Hideable.CellTemplateMixin'
    'Sortable.CellTemplateMixin'
  ]
