define [
  'oraculum'
  'oraculum/mixins/pub-sub'
  'oraculum/mixins/evented-method'
], (Oraculum) ->
  'use strict'

  $ = Oraculum.get 'jQuery'

  Oraculum.defineMixin 'Attach.ViewMixin', {
    mixinOptions:
      attach:
        auto: true
        container: null
        containerMethod: 'append'
      eventedMethods:
        render: {}
        attach: {}

    mixconfig: ({attach}, {autoAttach, container, containerMethod} = {}) ->
      attach.auto = autoAttach if autoAttach?
      attach.container = container if container?
      attach.containerMethod = containerMethod if containerMethod?

    mixinitialize: ->
      @on 'render:after', => @attach() if @mixinOptions.attach.auto

    attach: ->
      {container, containerMethod} = @mixinOptions.attach
      return unless container and containerMethod
      return if document.body.contains @el
      $(container)[containerMethod] @el
      @trigger 'addedToParent'

  }, mixins: [
    'EventedMethod.Mixin'
  ]
