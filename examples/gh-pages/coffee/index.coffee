# Modify objects in memory before we bootstrap the application
# Modifying entire applications in Oraculum is trivially easy.
define [
  'oraculum'

  'cs!ft/examples/gh-pages/coffee/templates/home'

  'fastTable/views/mixins/cell'
  'fastTable/views/mixins/variable-width-cell'

  'cs!libs'
  'cs!models/pages'
  'cs!ft/examples/gh-pages/coffee/models/column'
  'cs!ft/examples/gh-pages/coffee/models/github-event'
  'cs!ft/examples/gh-pages/coffee/views/github-event-table'
], (Oraculum, home) ->

  pages = Oraculum.get 'Pages.Collection'
  pages.__dispose()

  Oraculum.get 'Pages.Collection', [{
    id: 'home'
    name: 'Home'
    markdown: home
  }], parse: true

  makeEventedMethod = Oraculum.get 'makeEventedMethod'

  Oraculum.onTag 'Index.Controller', (controller) ->
    makeEventedMethod controller, 'index'

    controller.on 'index:after', ({page}) ->

      collection = Oraculum.get 'GithubEvent.Collection', [{
        'id', 'type',
        repo: {'name'}
        actor: {'login'}
      }]

      columns = Oraculum.get 'Columns', [{
        label: 'Unique Identifier'
        sortable: true
        attribute: 'id'
        template: ({column, model}) ->
          return "<td><span>#{model.get('id')}</span></td>"
        templateMixins: ['Cell.TemplateMixin', 'VariableWidth.CellTemplateMixin']
      }, {
        label: 'Actor'
        sortable: true
        attribute: 'actor.login'
        template: ({column, model}) ->
          return "<td><span>#{model.get('actor').login}</span></td>"
        templateMixins: ['Cell.TemplateMixin', 'VariableWidth.CellTemplateMixin']
      }, {
        label: 'Event Type'
        sortable: true
        attribute: 'type'
        template: ({column, model}) ->
          return "<td><span>#{model.get('type')}</span></td>"
        templateMixins: ['Cell.TemplateMixin', 'VariableWidth.CellTemplateMixin']
      }, {
        label: 'Repo Name'
        sortable: true
        attribute: 'repo.name'
        template: ({column, model}) ->
          return "<td><span>#{model.get('repo').name}</span></td>"
        templateMixins: ['Cell.TemplateMixin', 'VariableWidth.CellTemplateMixin']
      }], sortCollection: collection

      controller.reuse 'table-demo', 'GithubEvents.Table',
        container: '#fastTable-demo'
        collection: collection
        columns: columns

  # Bootstrap the app
  require ['cs!index']
