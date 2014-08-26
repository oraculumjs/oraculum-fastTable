define [
  'oraculum'
], (Oraculum) ->
  'use strict'

  ###
  DisposeRemoved.CollectionMixin
  ==============================
  Automatically `dispose` a `Model` that has been removed from a `Collection`.
  This mixin is intended to be used at the `Collection` layer so that it can
  ensure that it's not disposing of `Model`s that may have been removed from
  a separate `Collection`.
  ###

  Oraculum.defineMixin 'DisposeRemoved.CollectionMixin',

    ###
    Mixin Options
    -------------
    Allow the `disposeRemoved` flag to be set on the definition.
    ###

    mixinOptions:
      disposeRemoved: true # Whether or not to `dispose` removed `Model`s.

    ###
    Mixconfig
    ---------
    Allow the `disposeRemoved` flag to be set in the constructor options.

    @param {Boolean} disposeRemoved Whether or not to `dispose` removed `Model`s.
    ###

    mixconfig: (mixinOptions, models, {disposeRemoved} = {}) ->
      mixinOptions.disposeRemoved = disposeRemoved if disposeRemoved?

    ###
    Mixinitialize
    -------------
    Set up an event listener to respond to `remove` events by invoking `dispose`
    on the removed `Model`. Additionally, add an event listener to respond to
    `reset` events by invoking `dispose` on `Model`s that were removed during
    the `reset` operation.
    By design, this will throw if the target model does not impement the
    `dispose` method.
    ###

    mixinitialize: ->
      @on 'remove', (model) =>
        return unless @mixinOptions.disposeRemoved
        model.dispose()

      @on 'reset', (models, {previousModels}) =>
        return unless @mixinOptions.disposeRemoved
        _.invoke previousModels, 'dispose'
