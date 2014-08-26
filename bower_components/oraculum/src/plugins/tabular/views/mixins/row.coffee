define [
  'oraculum'
  'oraculum/views/mixins/list'
  'oraculum/views/mixins/static-classes'
], (Oraculum) ->
  'use strict'

  ###
  Row.ViewMixin
  =============
  ###

  Oraculum.defineMixin 'Row.ViewMixin', {

    mixinOptions:
      staticClasses: ['row-mixin']

    initModelView: (column) ->
      {modelView, viewOptions} = @mixinOptions.list

      modelView = column.get('modelView') or modelView
      throw new TypeError '''
        ColumList.ViewMixin modelView option must be defined.
      ''' unless modelView

      model = @model or column
      viewOptions = if _.isFunction viewOptions
      then viewOptions.call this, { model, column }
      else _.extend { model, column }, viewOptions

      viewOptions = _.extend {}, viewOptions, column.get 'viewOptions'
      return @createView { view: modelView , viewOptions }

  }, mixins: [
    'List.ViewMixin'
    'StaticClasses.ViewMixin'
  ]
