require [
  'oraculum'
  'oraculum/mixins/disposable'
], (Oraculum) ->

  Oraculum.extend 'Model', 'Disposable.Model', {
  }, mixins: ['Disposable.Mixin']
