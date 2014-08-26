define [
  'oraculum'
], (Oraculum) ->
  'use strict'

  ###
  Templating Interface
  ====================
  Provide simple common interface for configuring templating mixins.

  @see views/mixins/html-templating
  @see views/mixins/underscore-templating
  ###

  Oraculum.defineMixin 'TemplatingInterface.ViewMixin',

    ###
    Mixin Options
    -------------
    Allow the `template` to be configured directly on the definition.
    ###

    mixinOptions:
      template: ''

    ###
    Mixin Config
    ------------
    Allow the `template` to be configured at construction.
    ###

    mixconfig: (mixinOptions, {template} = {}) ->
      mixinOptions.template = template if template?
