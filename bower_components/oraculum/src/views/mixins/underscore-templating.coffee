define [
  'oraculum'
  'oraculum/libs'
  'oraculum/views/mixins/templating-interface'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  getTemplateData = ->
    data = {}
    _.extend data, @model.toJSON() if @model
    _.defaults data, {
      items: @collection.toJSON()
      length: @collection.length
    } if @collection
    return data

  getTemplateFunction = ->
    template = @mixinOptions.template
    template = template.call this if _.isFunction template
    _template = _.template template
    return (data) ->
      html = template
      try html = _template.call this, data
      finally return html

  Oraculum.defineMixin 'UnderscoreTemplating.ViewMixin', {

    mixinitialize: ->
      @getTemplateData ?= getTemplateData
      @getTemplateFunction ?= getTemplateFunction

    render: ->
      templateFunc = @getTemplateFunction()
      data = @getTemplateData()
      func = @getTemplateFunction()
      @$el.html func.call this, data
      return this

  }, mixins: [
    'TemplatingInterface.ViewMixin'
  ]
