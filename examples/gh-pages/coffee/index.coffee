# Modify objects in memory before we bootstrap the application
# Modifying entire applications in Oraculum is trivially easy.
define [
  'oraculum'

  'cs!ft/examples/gh-pages/coffee/templates/home'

  'cs!libs'
  'cs!models/pages'
  'fastTable/views/mixins/fast-row'
  'oraculum/views/mixins/html-templating'
  'oraculum/plugins/tabular/views/mixins/cell'
  'oraculum/plugins/tabular/views/mixins/table'
  'oraculum/plugins/tabular/views/mixins/variable-width-cell'
], (Oraculum, home) ->
  'use strict'

  pages = Oraculum.get 'Pages.Collection'
  pages.__dispose()

  Oraculum.get 'Pages.Collection', [{
    id: 'home'
    name: 'Home'
    markdown: home
  }], parse: true

  Oraculum.extend 'View', 'FastRow.View', {
    tagName: 'tr'
  }, mixins: ['FastRow.ViewMixin']

  Oraculum.extend 'View', 'Table.View', {
    tagName: 'table'
    className: 'table table-bordered table-hover table-striped'
    mixinOptions:
      list:
        modelView: 'FastRow.View'
        listSelector: 'tbody'
      template: '<tbody/>'
  }, {
    singleton: true
    mixins: [
      'Table.ViewMixin'
      'Attach.ViewMixin'
      'HTMLTemplating.ViewMixin'
      'AutoRender.ViewMixin'
    ]
  }

  Oraculum.onTag 'Index.Controller', (controller) ->

    makeEventedMethod = Oraculum.get 'makeEventedMethod'
    makeEventedMethod controller, 'index'

    controller.on 'index:after', ({page}) ->

      collection = Oraculum.get 'Collection', _.map [0..200], (id) -> {
        id: id
        type: "type-#{id}"
        repo: "repo-#{id}"
        actor: "user-#{id}"
      }

      columns = Oraculum.get 'Collection', [{
        label: 'Unique Identifier'
        attribute: 'id'
        template: ({column, model}) -> "<td>#{model.get 'id'}</td>"
        templateMixins: ['Cell.ViewMixin', 'VariableWidth.CellMixin']
      }, {
        label: 'Actor'
        attribute: 'actor'
        template: ({column, model}) -> "<td>#{model.get 'actor'}</td>"
        templateMixins: ['Cell.ViewMixin', 'VariableWidth.CellMixin']
      }, {
        label: 'Event Type'
        attribute: 'type'
        template: ({column, model}) -> "<td>#{model.get 'type'}</td>"
        templateMixins: ['Cell.ViewMixin', 'VariableWidth.CellMixin']
      }, {
        label: 'Repo Name'
        attribute: 'repo'
        template: ({column, model}) -> "<td>#{model.get 'repo'}</td>"
        templateMixins: ['Cell.ViewMixin', 'VariableWidth.CellMixin']
      }], sortCollection: collection

      controller.reuse 'table-demo', 'Table.View',
        columns: columns
        container: '#fastTable-demo'
        collection: collection

  # Bootstrap the app
  require ['cs!index']
