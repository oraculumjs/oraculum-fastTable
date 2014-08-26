define [
  'oraculum'
  'oraculum/libs'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  ###
  DisposeDestroyed.ModelMixin
  ===========================
  Automatically `dispose` a `Model` that has been destroyed.
  This mixin is written such that it can be used at the `Model` layer or at the
  `Collection` layer.
  ###

  Oraculum.defineMixin 'DisposeDestroyed.ModelMixin',

    ###
    Mixin Options
    -------------
    Allow the `disposeDestroyed` flag to be set on the definition.
    ###

    mixinOptions:
      disposeDestroyed: true # Whether or not to `dispose` destroyed `Model`s.

    ###
    Mixconfig
    ---------
    Allow the `disposeDestroyed` flag to be set in the constructor options.

    @param {Boolean} disposeDestroyed Whether or not to `dispose` destroyed `Model`s.
    ###

    mixconfig: (mixinOptions, models, {disposeDestroyed} = {}) ->
      mixinOptions.disposeDestroyed = disposeDestroyed if disposeDestroyed?

    ###
    Mixinitialize
    -------------
    Set up an event listener to respond to `destroy` events by invoking
    `dispose` on the destroyed `Model`.
    By design, this will throw if the target `model` does not implement the
    `dispose` method.
    ###

    mixinitialize: ->
      @on 'destroy', (model) =>
        return unless @mixinOptions.disposeDestroyed
        # Due to Backbone's behavior of triggering `destroy` before `sync`, we
        # defer the invocation of `dispose` to allow any `sync` callbacks to
        # clear the stack.
        # Additionally, we use the passed through `model` as the disposal target
        # to allow this mixin to be used on `Collection`s.
        _.defer -> model.dispose()
