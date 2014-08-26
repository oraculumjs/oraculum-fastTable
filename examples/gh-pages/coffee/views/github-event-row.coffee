define [
  'oraculum'
  'fastTable/views/mixins/fast-row'
  'fastTable/views/mixins/hideable-cell'
], (Oraculum) ->
  'use strict'

  # Extend a view to make it behave like a row
  Oraculum.extend 'View', 'GithubEvent.Row', {
    tagName: 'tr'
  }, mixins: [
    'FastRow.ViewMixin'
  ]
