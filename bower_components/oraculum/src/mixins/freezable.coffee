define [
  'oraculum'
  'oraculum/mixins/evented-method'
], (Oraculum) ->
  'use strict'

  ###
  Freezable.Mixin
  ===============
  Allow an object to be frozen immediately after construction and provide
  a freezable interface.
  ###

  Oraculum.defineMixin 'Freezable.Mixin', {

    ###
    Mixin Options
    -------------
    Allow the object to be configured to be frozen immediately after
    construction. Default to false.
    ###

    mixinOptions:
      freeze: false

    ###
    Minitialize
    -----------
    Configure the instance and perform the freeze operation.
    ###

    mixinitialize: ->
      # Return immediately unless we're configure to freeze.
      return unless @mixinOptions.freeze is true
      # Set a constructed method if one doesn't already exist.
      @constructed ?= -> # '\x90'
      # Event the constructed method so we can hook the after event.
      @makeEventedMethod 'constructed'
      # Hook our freeze operation into the constructed method's after event.
      @on 'constructed:after', @freeze, this

    ###
    Freeze
    ------
    The freeze interface.
    Invoke the freezse method on this instance if it's available.
    ###

    freeze: -> # You’re frozen when your heart’s not open.
      Object.freeze? this

    ###
    Is Frozen
    ---------
    Check to see if this instance is frozen.

    @return {Boolean} Whether this instance is frozen.
    ###

    isFrozen: ->
      return Object.isFrozen? this

  }, mixins: [
    'EventedMethod.Mixin'
  ]
