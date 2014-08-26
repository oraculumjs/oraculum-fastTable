define [
  'oraculum'
], (Oraculum) ->
  'use strict'

  # This mixin should always come last if any other mixins in the depedency
  # chain somehow depend on `render` being invoked after they've initialized

  Oraculum.defineMixin 'AutoRender.ViewMixin',
    mixinOptions:
      autoRender: true

    mixconfig: (mixinOptions, {autoRender} = {}) ->
      mixinOptions.autoRender = autoRender if autoRender?

    mixinitialize: ->
      @render() if @mixinOptions.autoRender is true
