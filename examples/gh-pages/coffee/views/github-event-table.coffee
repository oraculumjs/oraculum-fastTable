define [
  'oraculum'
  'oraculum/views/mixins/attach'
  'oraculum/views/mixins/auto-render'
  'oraculum/views/mixins/html-templating'
  'oraculum/plugins/tabular/views/mixins/table'
  'muTable/views/mixins/mutable-column-width'
  'cs!ft/examples/gh-pages/coffee/views/github-event-row'
  'cs!ft/examples/gh-pages/coffee/views/table-header-row'
], (Oraculum) ->
  'use strict'

  # Extend a view to make it behave like a table
  Oraculum.extend 'View', 'GithubEvents.Table', {
    tagName: 'table'
    className: 'table table-striped table-hover table-bordered'

    mixinOptions:
      subviews:
        header: ->
          view: 'TableHeader.Row'
          viewOptions:
            container: @$ 'thead'
            collection: @columns
      list:
        modelView: 'GithubEvent.Row'
        listSelector: 'tbody'
      muTableColumnWidth:
        cellSelector: 'td.cell-mixin'
      template: '<thead/><tbody/>'

  }, {
    singleton: true
    mixins: [
      'Table.ViewMixin'
      'Attach.ViewMixin'
      'HTMLTemplating.ViewMixin'
      'muTableColumnWidth.TableMixin'
      'AutoRender.ViewMixin'
    ]
  }
