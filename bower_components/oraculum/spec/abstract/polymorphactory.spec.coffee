require [
  'oraculum'
  'oraculum/abstract/polymorphactory'
], (Oraculum) ->
  'use strict'

  describe 'PolymorPhactory', ->

    it 'should throw if not extended with a "getTypeString" method', ->
      expect(-> Oraculum.get 'PolymorPhactory').toThrow()

    describe 'extended behavior', ->
      namedDef = -> {'namedDef'}
      mappedDef = -> {'mappedDef'}

      Oraculum.define 'namedDef', namedDef
      Oraculum.define 'mappedDef', mappedDef

      Oraculum.extend 'PolymorPhactory', 'Named.Test.PolymorPhactory',
        getTypeString: -> 'namedDef'

      Oraculum.extend 'PolymorPhactory', 'Mapped.Test.PolymorPhactory',
        getTypeString: -> 'mappedValue'
        typeMap: mappedValue: 'mappedDef'

      it 'should retrieve the correct named definition from the factory if no typeMap is specified', ->
        instance = Oraculum.get 'Named.Test.PolymorPhactory'
        expect(instance).toImplement namedDef()

      it 'should retrieve the correct mapped definition from the factory if typeMap is specified', ->
        instance = Oraculum.get 'Mapped.Test.PolymorPhactory'
        expect(instance).toImplement mappedDef()
