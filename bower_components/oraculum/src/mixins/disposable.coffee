define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/evented'
  'oraculum/mixins/freezable'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  ###
  Disposable.Mixin
  ================
  This mixin is the heart of the memory management in Oraculum.
  Originally derived from Chaplin's per-class dispose() implementations,
  this mixin provides disposal in a uniform way that can be applied to any
  definition provided by Oraculum.
  ###

  Oraculum.defineMixin 'Disposable.Mixin', {

    ###
    Mixin Options
    -------------
    Provide a namespace for disposable configuration and expose the
    `disposeAll` configuration option. When true, the `dispose` method
    will attempt to invoke `dispose` on any top-level attribute of the
    instance it was called on.
    ###

    mixinOptions:
      disposable:
        disposeAll: false

    ###
    Dispose
    -------
    The disposal interface.
    ###

    dispose: ->
      # Gate the method based on the disposed state of the instance.
      return this if @disposed

      # Provide event hooks for SRP disposal. I.e. if any mixed in behavior
      # creates non-primitive memory-unsafe objects, notify them of the
      # impending disposal of this instance, and allow them an opportunity
      # to clean up after themselves.

      @trigger 'dispose:before', this
      @trigger 'dispose', this
      @disposed = true
      @trigger 'dispose:after', this

      # Remove all event listeners from the instance.
      @off()
      @stopListening()

      # Dispose of any disposable properties if the `disposeAll` bit it set.
      if @mixinOptions.disposable?.disposeAll
        _.each this, (prop, name) -> prop?.dispose?()

      # Delete all of our non-object primitives, assuming we're not frozen.
      unless Object.isFrozen? this
        _.each this, (prop, name) =>
          return if _.isFunction prop
          return unless _.isObject prop
          delete @[name]

      # Freeze the instance to prevent further changes.
      @freeze()

      # Finally, remove the instance from the factory.
      @__dispose this if @__factory().verifyTags this

  }, mixins: [
    'Evented.Mixin'
    'Freezable.Mixin'
  ]
