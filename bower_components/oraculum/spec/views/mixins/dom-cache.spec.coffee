require [
  'oraculum'
  'oraculum/views/mixins/dom-cache'
  'oraculum/views/mixins/html-templating'
], (Oraculum) ->
  'use strict'

  describe 'DOMCache.ViewMixin', ->
    domcache = {'span', '#id', '.class', '[attribute="attribute"]'}
    template = '''
      <span/>
      <div id="id"/>
      <div class="class"/>
      <div attribute="attribute"/>
      <div data-cache="data_attribute"/>
      <div class="not-cached" />
    '''

    Oraculum.extend 'View', 'DOMCache.View', {
      mixinOptions: {template, domcache}
    }, mixins: [
      'DOMCache.ViewMixin'
      'HTMLTemplating.ViewMixin'
    ]

    dependsMixins Oraculum, 'DOMCache.ViewMixin',
      'Evented.Mixin'
      'EventedMethod.Mixin'

    it 'should read domcache at construction', ->
      view = Oraculum.get 'DOMCache.View'
      expect(view.mixinOptions.domcache).toEqual domcache
      expect(view.mixinOptions.domcache).not.toBe domcache
      view.__dispose()
      view = Oraculum.get 'DOMCache.View', domcache: {'.ctor'}
      expect(view.mixinOptions.domcache).not.toEqual domcache
      expect(view.mixinOptions.domcache).toImplement {'.ctor'}
      view.__dispose()

    it 'should cache dom nodes by domcache config', ->
      view = Oraculum.get 'DOMCache.View'
      expect(view.domcache).toBeUndefined()
      view.render()
      expect(view.domcache).toBeObject()
      expect(view.domcache['span']).toBe view.$ 'span'
      expect(view.domcache['#id']).toBe view.$ '#id'
      expect(view.domcache['.class']).toBe view.$ '.class'
      expect(view.domcache['[attribute="attribute"]']).toBe view.$ '[attribute="attribute"]'
      view.__dispose()

    it 'should cache dom nodes by data-cache attributes', ->
      view = Oraculum.get 'DOMCache.View'
      expect(view.domcache).toBeUndefined()
      view.render()
      expect(view.domcache).toBeObject()
      expect(view.domcache['data_attribute']).toBe view.$ '[data-cache="data_attribute"]'
      view.__dispose()

    it 'should trigger a "domcache" when the domcache object is available', ->
      view = Oraculum.get 'DOMCache.View'
      callback = -> expect(@domcache).toBeObject()
      domcacheSpy = sinon.spy callback
      view.on 'domcache', domcacheSpy, view
      expect(view.domcache).toBeUndefined()
      view.render()
      expect(domcacheSpy).toHaveBeenCalledOnce()
      view.__dispose()

    it 'should cache a single element', ->
      view = Oraculum.get 'DOMCache.View'
      view.render()
      view.cacheElement '.not-cached', 'singleElement'
      expect(view.domcache.singleElement).toBe view.$ '.not-cached'
      view.__dispose()
