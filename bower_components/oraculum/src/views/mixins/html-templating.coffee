define [
  'oraculum'
  'oraculum/views/mixins/templating-interface'
], (Oraculum) ->
  'use strict'

  Oraculum.defineMixin 'HTMLTemplating.ViewMixin', {

    render: ->
      template = @mixinOptions.template
      template = template.call this if typeof template is 'function'
      @$el.html template
      return this

  }, mixins: [
    'TemplatingInterface.ViewMixin'
  ]
