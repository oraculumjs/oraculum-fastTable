define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/evented'
  'oraculum/extensions/make-evented-method'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'
  makeEventedMethod = Oraculum.get 'makeEventedMethod'

  ###
  Make Evented Method
  ===================
  This mixin exposes the heart of our dynamic AOP-based decoupling.

  @see extensions/make-evented-method.coffee
  ###

  Oraculum.defineMixin 'EventedMethod.Mixin', {

    ###
    Mixin Options
    -------------
    Allow the targeting of our instance methods to be evented using a mapping
    of method names and evented method spec as described in the examples below.

    @param {Object} eventedMethods Object containing the eventing map.
    ###

    #### Example configuration ###
    # ```coffeescript
    # mixinOptions:
    #   eventedMethods:
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
    Invoke `@makeEventedMethods`.

    @see @makeEventedMethods
    ###

    mixinitialize: ->
      @makeEventedMethods()

    ###
    Make Evented Methods
    --------------------
    Iterate over the eventing map, passing our method names and their eventing
    specs through to `@makeEventedMethod`.

    @see @makeEventedMethod

    @param {Array} eventingMap? An eventing map. Defaults to our configured eventing map.
    ###

    makeEventedMethods: (eventingMap) ->
      return unless eventingMap ?= @mixinOptions.eventedMethods
      _.each eventingMap, ({emitter, trigger, prefix}, method) =>
        @makeEventedMethod method, emitter, trigger, prefix

    ###
    Make Evented Method
    -------------------
    A proxy for the global `makeEventedMethod` function.
    Forces the evented method's scope to `this`.
    ###

    makeEventedMethod: ->
      makeEventedMethod this, arguments...

  }, mixins: [
    'Evented.Mixin'
  ]
