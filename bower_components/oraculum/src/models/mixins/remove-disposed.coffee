define [
  'oraculum'
], (Oraculum) ->
  'use strict'

  Oraculum.defineMixin 'RemoveDisposed.CollectionMixin',

    mixinOptions:
      removeDisposed: true

    mixconfig: (mixinOptions, models, {removeDisposed} = {}) ->
      mixinOptions.removeDisposed = removeDisposed if removeDisposed?

    mixinitialize: ->
      if @mixinOptions.removeDisposed
      then @enableRemoveDisposed()
      else @disableRemoveDisposed()

    enableRemoveDisposed: ->
      @on 'dispose:after', @removeDisposed, this

    disableRemoveDisposed: ->
      @off 'dispose:after', @removeDisposed, this

    removeDisposed: (model) ->
      return if model is this
      @remove model
