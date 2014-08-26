define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/evented'
  'oraculum/mixins/evented-method'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  Oraculum.defineMixin 'DOMCache.ViewMixin', {

    # Example subviews configuration
    # ------------------------------
    # ```coffeescript
    # mixinOptions:
    #   domcache:
    #     name: 'selector'
    # ```

    mixinOptions:
      eventedMethods:
        render: {}

    mixconfig: (mixinOptions, {domcache} = {}) ->
      mixinOptions.domcache = _.extend {}, mixinOptions.domcache, domcache

    mixinitialize: ->
      @on 'render:after', @cacheDOM, this

    cacheDOM: ->
      @domcache = {}
      _.each @$('[data-cache]'), @cacheElement, this
      _.each @mixinOptions.domcache, @cacheElement, this
      @trigger 'domcache', this

    cacheElement: (element, name) ->
      $element = @$ element
      name = $element.attr 'data-cache' if _.isElement element
      @domcache[name] = $element if name and $element.length

  }, mixins: [
    'Evented.Mixin'
    'EventedMethod.Mixin'
  ]
