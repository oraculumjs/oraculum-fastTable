require [
  'oraculum'
  'Factory'
  'BackboneFactory'
], (Oraculum, Factory, BackboneFactory) ->
  'use strict'

  describe 'Oraculum', ->

    it 'should be a factory', ->
      expect(Oraculum).toBeInstanceOf Factory
