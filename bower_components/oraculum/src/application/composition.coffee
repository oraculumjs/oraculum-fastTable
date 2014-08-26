define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/evented'
  'oraculum/mixins/disposable'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'
  Backbone = Oraculum.get 'Backbone'

  ###
  Composition
  ===========
  The role of a composition is to control the lifecycle of a view between
  controller actions.
  Compositions are managed by the `Composer` and used to track and maintain
  the state of an interlying `item`.
  Currently, the `Composer` is only intended to manage `View`s.

  @see application/composer.coffee
  @see http://backbonejs.org/#View
  ###

  Oraculum.define 'Composition', (class Composition

    ###
    State variable tracking the composed item.

    @type {View}
    ###

    item: null

    ###
    State variable tracking whether the composed item is "stale".
    A composition becomes "stale" when the controlling `Composer` receives
    the `dispatcher:dispatch` event from the global message bus, indicating
    that the current dispatch cycle has been completed.

    @type {Boolean}
    ###

    _stale: false

    ###
    A local cache of the options that this composition was constructed with.

    @type {Object}
    ###

    options: null


    ###
    Constructor
    -----------

    @param {Object} options The options to be used to construct/test our composed `View`
    ###

    constructor: (options) ->
      # Assign `@item` to `this` by default.
      # This supports function-driven composition patterns.
      @item = this
      # Clone and ensure that `options` is an object.
      @options = _.extend {}, options
      # Invoke `@initialize` if it's available.
      @initialize? arguments...

    ###
    Mixin Options
    -------------
    Instruct the `Disposable.Mixin` to dispose all of our properties upon
    disposal.

    @see mixins/disposable.coffee
    ###

    mixinOptions:
      disposable:
        disposeAll: true

    ###
    Compose
    -------
    The compose method is called to construct the underlying `View`.
    It is a no-op method by default, and gets assigned during the `Composer`'s
    `_compose` method.

    @see application/composer.coffee
    ###

    compose: -> # Empty per default.

    ###
    Check
    -----
    This method is called when the `Composer` attempts to re-compose this
    composition. The default implementation checks if the keys/values of
    `options` are the same as the keys/values of `@options`, however this method
    may be overridden during the `Composer`'s `_compose` method.

    @see application/composer.coffee

    @param {Object} options The options for the new composition.

    @return {Boolean} Whether `options` matches `@options`
    ###

    check: (options) -> _.isEqual options, @options

    ###
    Stale
    -----
    Getter/setter for the `@_stale` property.

    @param {Undefined} value Gets the current value of `@_stale`.
    @param {Boolean} value Sets the current value of `@_stale`.

    @return {Boolean?} The value of `@_stale` if `value` is `undefined`.
    ###

    stale: (value) ->
      # Return the current property if not requesting a change.
      return @_stale unless value?

      # Set the stale property for every item in the composition that has it.
      @_stale = value
      _.each this, (property, name) ->
        return if property is this
        return unless property?
        return unless property._stale?
        property._stale = value

      return # undefined

  ), mixins: [
    'Evented.Mixin'
    'Disposable.Mixin'
  ]
