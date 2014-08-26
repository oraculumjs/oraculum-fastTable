define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/evented'
  'oraculum/extensions/make-middleware-method'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'
  makeMiddlewareMethod = Oraculum.get 'makeMiddlewareMethod'

  ###
  Make Middleware Method
  ===================
  This mixin exposes the heart of our dynamic AOP-based decoupling.

  @see extensions/make-middleware-method.coffee
  ###

  Oraculum.defineMixin 'MiddlewareMethod.Mixin', {

    ###
    Mixin Options
    -------------
    Allow the targeting of our instance methods to be middlewared using a mapping
    of method names and middlewared method spec as described in the examples below.

    @param {Object} middlewaredMethods Object containing the middleware map.
    ###

    #### Example configuration ###
    # ```coffeescript
    # mixinOptions:
    #   middlewaredMethods:
    #     # Hook the `render` method using defaults.
    #     render: {}
    #
    #     # Hook the `attach` method using defaults.
    #     attach:
    #       emitter: null # defaults to this instance
    #       trigger: null # defaults to 'trigger'
    #
    #     # Hook the `subview` method using `Backbone` as the
    #     # event emitter and prefix its event names with
    #     # `SomeView:`.
    #     subview:
    #       emitter: Backbone
    #       eventPrefix: 'SomeView'
    #
    #     # Hook the `getTemplateData` method using `publishEvent`
    #     # as the triggering mechanism.
    #     getTemplateData:
    #       trigger: 'publishEvent'
    #
    #     # Hook the view element selector using the view's
    #     # element as the emitter and the `fire` event as the
    #     # triggering mechanism.
    #     $: ->
    #       emitter: @$el
    #       trigger: 'fire'
    # ```

    ###
    Mixinitialize
    -------------
    Invoke `@makeMiddlewareMethods`.

    @see @makeMiddlewareMethods
    ###

    mixinitialize: ->
      @makeMiddlewareMethods()

    ###
    Make Middleware Methods
    --------------------
    Iterate over the middleware map, passing our method names and their
    middleware specs through to `@makeMiddlewareMethod`.

    @see @makeMiddlewareMethod

    @param {Array} middlewareMap? An middleware map. Defaults to our configured middleware map.
    ###

    makeMiddlewareMethods: (middlewareMap) ->
      return unless middlewareMap ?= @mixinOptions.middlewaredMethods
      _.each middlewareMap, ({emitter, trigger, prefix}, method) =>
        @makeMiddlewareMethod method, emitter, trigger, prefix

    ###
    Make Middleware Method
    -------------------
    A proxy for the global `makeMiddlewareMethod` function.
    Forces the middlewared method's scope to `this`.
    ###

    makeMiddlewareMethod: ->
      makeMiddlewareMethod this, arguments...

  }, mixins: [
    'Evented.Mixin'
  ]
