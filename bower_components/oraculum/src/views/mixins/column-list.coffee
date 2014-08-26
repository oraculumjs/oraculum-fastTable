###
This file is a stub for convenience
===================================
This file will be removed in 2.0
###

define [
  'oraculum'
  'oraculum/plugins/tabular/views/mixins/row'
], (Oraculum) ->
  'use strict'

  console?.warn? 'Oraculum\'s tabular interface has moved. See /plugins/tabular'
  console?.warn? 'ColumnList.ViewMixin is now Row.ViewMixin'
  Oraculum.defineMixin 'ColumnList.ViewMixin', {}, mixins: ['Row.ViewMixin']
