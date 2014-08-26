require [
  'oraculum'
  'oraculum/application/composition'
], (Oraculum) ->
  'use strict'

  describe 'Composition', ->
    Composition = Oraculum.getConstructor 'Composition'
    definition = Oraculum.definitions['Composition']
    ctor = definition.constructor

    composition = null

    beforeEach ->
      # Instantiate
      composition = new Composition

    afterEach ->
      # Dispose
      composition.dispose()
      composition = null

    containsMixins definition,
      'Disposable.Mixin'

    # initialize
    # ----------

    it 'should initialize', ->
      expect(composition.stale()).toBeFalse()
      expect(composition.item).toBe composition
