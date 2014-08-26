define [
  'oraculum'
  'oraculum/views/mixins/attach'
  'oraculum/views/mixins/auto-render'
  'oraculum/plugins/tabular/views/mixins/row'
  'oraculum/plugins/tabular/views/cells/header'
  'muTable/views/mixins/mutable-column-order-cell'
], (Oraculum) ->
  'use strict'

  Oraculum.extend 'Header.Cell', 'TableHeader.Cell', {
    tagName: 'th'
  }, {
    inheritMixins: true
    mixins: ['muTableColumnOrder.CellMixin']
  }

  Oraculum.extend 'View', 'TableHeader.Row', {
    tagName: 'tr'
    mixinOptions:
      list: modelView: 'TableHeader.Cell'
  }, mixins: [
    'Row.ViewMixin'
    'Attach.ViewMixin'
    'AutoRender.ViewMixin'
  ]
