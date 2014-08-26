define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/evented'
], (Oraculum) ->
  'use strict'

  Backbone = Oraculum.get 'Backbone'

  ###
  PubSub.Mixin
  ============
  This mixin provides an interface to our global event bus.
  For the sake of simplicity, `Backbone` act as our global event bus.

  @see http://backbonejs.org/#Events-catalog
  ###

  Oraculum.defineMixin 'PubSub.Mixin', {

    ###
    Publish Event
    -------------
    Trigger an event on the global event bus.

    @param {String} name The event to trigger.
    @param {Mixed} args... Any arguments pass through the event.
    ###

    publishEvent: (name, args...) ->
      Backbone.trigger name, args...

    ###
    Subscribe Event
    ---------------
    Listen for events on the global event bus.

    @param {String} name The event(s) name to listen for.
    @param {Function} callback The function to bind to the event.
    ###

    subscribeEvent: (name, callback) ->
      @listenTo Backbone, name, callback

    ###
    Subscribe Once
    --------------
    Listen for events on the global event bus and immediately remove the
    listener after it's been invoked once.

    @param {String} name The event(s) name to listen for.
    @param {Function} callback The function to bind to the event.
    ###

    subscribeOnce: (name, callback) ->
      @listenToOnce Backbone, name, callback

    ###
    Unsubscribe Event
    -----------------
    Stop listening to events on the global event bus.

    @param {String} name The event(s) to stop listening for.
    @param {Function} callback? The function to stop binding.
    ###

    unsubscribeEvent: (name, callback) ->
      @stopListening Backbone, name, callback

  }, mixins: [
    'Evented.Mixin'
  ]
