define [
  'oraculum'
  'oraculum/libs'
], (Oraculum) ->
  'use strict'

  Backbone = Oraculum.get 'Backbone'

  ###
  Evented.Mixin
  =============
  By making Backbone's Events mixin a proper mixin, we don't have to rely on
  any object in the system to have previously implemented Backbone's eventing
  interface implicitly. We can instead require it explicitly and ensure that any
  mixin that relies on eventing behaviors has those behaviors available using
  FactoryJS's mixin dependency chaining.
  ###

  Oraculum.defineMixin 'Evented.Mixin', Backbone.Events
