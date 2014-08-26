define [
  'oraculum'
  'oraculum/views/mixins/list'
  'oraculum/views/mixins/static-classes'
], (Oraculum) ->
  'use strict'

  Oraculum.defineMixin 'Table.ViewMixin', {

    mixinOptions:
      staticClasses: ['table-mixin']
      table: columns: null

    mixconfig: ({table, list}, {columns} = {}) ->
      table.columns = columns if columns?
      viewOptions = list.viewOptions
      list.viewOptions = unless _.isFunction viewOptions
      then _.extend { collection: table.columns }, viewOptions
      else -> _.extend {
        collection: table.columns
      }, viewOptions.apply this, arguments

    mixinitialize: ->
      @columns = @mixinOptions.table.columns
      @columns = @__factory().get @columns if _.isString @columns

  }, mixins: [
    'List.ViewMixin'
    'StaticClasses.ViewMixin'
  ]
