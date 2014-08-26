define [
  'oraculum'
  'oraculum/mixins/disposable'
], (Oraculum) ->
  'use strict'

  ###
  Disposable.CollectionMixin
  ==========================
  Extend the functionality of `Disposable.Mixin` to automatically dispose
  models belonging to a collection when the collection is disposed.

  @see mixins/disposable.coffee
  ###

  Oraculum.defineMixin 'Disposable.CollectionMixin', {

    ###
    MixinOptions
    ------------
    Allow the model disposal behavior to be configured by extending the
    `disposable` configuration with the `disposeModels` flag.
    Default is false.
    ###

    mixinOptions:
      disposable:
        disposeModels: false

    ###
    Mixconfig
    ---------
    Allow the `disposeModels` flag to passed in the contructor options.

    @param {Boolean} disposeModels Set the `disposeModels` flag.
    ###

    mixconfig: ({disposable}, models, {disposeModels} = {}) ->
      disposable.disposeModels = disposeModels if disposeModels?

    ###
    Mixinitialize
    -------------
    Set up an event listener to react to the disposal of this instance.
    ###

    mixinitialize: ->
      @on 'dispose', (target) =>
        # Ensure that the disosed target is in fact this instance.
        return unless target is this
        # Ensure that we're configured to dispose of our models.
        return unless @mixinOptions.disposable.disposeModels
        # Invoke dispose on all of our models. This will throw if this
        # collection contains any models that fail to implement the `disposable`
        # interface.
        _.invoke @models, 'dispose'

  }, mixins: [
    'Disposable.Mixin'
  ]
