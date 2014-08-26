define [
  'oraculum'
], (Oraculum) ->
  'use strict'

  # Simple finite state machine for synchronization of models/collections
  # Three states: unsynced, syncing and synced
  # Several transitions between them
  # Fires Backbone events on every transition
  # (unsynced, syncing, synced; syncStateChange)
  # Provides shortcut methods to call handlers when a given state is reached
  # (named after the events above)

  SYNCED   = 'synced'
  SYNCING  = 'syncing'
  UNSYNCED = 'unsynced'

  STATE_CHANGE = 'syncStateChange'

  SyncMachine =

    # Set up the object
    mixinitialize: ->
      @_syncState = UNSYNCED
      @_previousSyncState = null
      @on 'request', @beginSync, this
      @on 'error', @abortSync, this
      @on 'sync', @finishSync, this

    # Get the current state
    # ---------------------
    syncState: -> @_syncState
    isSynced: -> @_syncState is SYNCED
    isSyncing: -> @_syncState is SYNCING
    isUnsynced: -> @_syncState is UNSYNCED

    # Transitions
    # -----------
    unsync: ->
      return unless @_syncState in [SYNCING, SYNCED]
      @_previousSync = @_syncState
      @_syncState = UNSYNCED
      @trigger @_syncState, this, @_syncState
      @trigger STATE_CHANGE, this, @_syncState

    beginSync: ->
      return unless @_syncState in [UNSYNCED, SYNCED]
      @_previousSync = @_syncState
      @_syncState = SYNCING
      @trigger @_syncState, this, @_syncState
      @trigger STATE_CHANGE, this, @_syncState

    finishSync: ->
      return unless @_syncState is SYNCING
      @_previousSync = @_syncState
      @_syncState = SYNCED
      @trigger @_syncState, this, @_syncState
      @trigger STATE_CHANGE, this, @_syncState

    abortSync: ->
      return unless @_syncState is SYNCING
      @_syncState = @_previousSync
      @_previousSync = @_syncState
      @trigger @_syncState, this, @_syncState
      @trigger STATE_CHANGE, this, @_syncState

  # Create shortcut methods to bind a handler to a state change
  # -----------------------------------------------------------
  for event in [UNSYNCED, SYNCING, SYNCED, STATE_CHANGE]
    do (event) ->
      SyncMachine[event] = (callback, context = this) ->
        @on event, callback, context
        callback.call(context) if @_syncState is event

  # Export SyncMachine as a proper mixin
  # ------------------------------------
  Oraculum.defineMixin 'SyncMachine.ModelMixin', SyncMachine
