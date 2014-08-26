define [
  'oraculum'
  'oraculum/mixins/listener'
  'oraculum/mixins/disposable'
  'oraculum/mixins/evented-method'
  'oraculum/views/mixins/static-classes'
  'oraculum/views/mixins/html-templating'
  'oraculum/plugins/tabular/views/mixins/cell'
], (Oraculum) ->
  'use strict'
  ###
  Checkbox.Cell
  =============
  This cell provides a simple checkbox for representing the boolean state
  of an attribute on a model. It supports two-way binding to the model.

  Like all other concrete implementations in Oraculum, this class exists as a
  convenience/example. Please feel free to override or simply not use this
  definition.
  ###

  Oraculum.extend 'View', 'Checkbox.Cell', {

    events:
      'change input': '_updateModel'

    mixinOptions:
      staticClasses: ['checkbox-cell-view']

      # We use the `EventedMethod.Mixin` to event the `render` method so
      # that we can update the state of the checkbox as soon as it's available.
      eventedMethods:
        render: {}

      # We listen to the 'render:after' by providing the following configuration
      # syntax provided by the `Listener.Mixin`.
      listen:
        'render:after this': '_updateCheckbox'

      # We provide a simple html template for a checkbox that will be rendered
      # thanks to the `HTMLTemplating.ViewMixin`.
      template: '''
        <input type="checkbox" />
      '''

    # Constructed
    # -----------
    # Since our column could possibly change the attribute of the model this
    # cell is rendering, we abstract our model binding logic into a separate
    # method. This allows us to repeat our model binding logic without code
    # duplication.

    constructed: ->
      @listenTo @column, 'change:attribute', @_resetModelListener
      @_resetModelListener()

    # Reset Model Listener
    # --------------------
    # This is the abstraction of our model binding that allows us to change
    # the attribute we're rendering without losing our binding behavior.

    _resetModelListener: ->
      # If there was a previous attribute we were binding to, remove the binding
      if previous = @column.previous 'attribute'
        @stopListening @model, "change:#{previous}", @_updateCheckbox

      # Then bind to the new attribute
      current = @column.get 'attribute'
      @listenTo @model, "change:#{current}", @_updateCheckbox

      # And update our view to reflect the change
      @_updateCheckbox()

    # Update Checkbox
    # ---------------
    # This simply updates the 'checked' attibute of our checkbox input.
    # It implements the design principal that is a common mantra in Backbone:
    #
    # > Render once, update often.
    # > - @egeste
    #
    # If the value this node is bound to changes, make sure the node gets
    # updated to reflect that. No need to re-render the whole view.

    _updateCheckbox: ->
      attribute = @column.get 'attribute'
      checked = Boolean @model.get attribute
      @$('input').prop 'checked', checked

    # Update Model
    # ------------
    # And of course, this is the same as `_updateCheckbox` in reverse.
    # If the value of the node this model is bound to changes, update the model
    # to reflect the change.

    _updateModel: ->
      checked = @$('input').is ':checked'
      attribute = @column.get 'attribute'
      @model.set attribute, checked

  }, mixins: [
    'Listener.Mixin'
    'Disposable.Mixin'
    'EventedMethod.Mixin'
    'Cell.ViewMixin'
    'StaticClasses.ViewMixin'
    'HTMLTemplating.ViewMixin'
  ]
