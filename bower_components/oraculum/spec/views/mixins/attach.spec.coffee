require [
  'oraculum'
  'oraculum/views/mixins/attach'
  'oraculum/views/mixins/auto-render'
], (Oraculum) ->
  'use strict'

  describe 'Attach.ViewMixin', ->
    view = null
    testbed = null
    renderCalled = false

    Oraculum.extend 'View', 'Attach.View', {
      id: 'attach-view'
      mixinOptions:
        attach:
          auto: true
          container: 'container1'
          containerMethod: 'append'
    }, mixins: ['Attach.ViewMixin']

    beforeEach ->
      renderCalled = false
      testbed = createTestbed()
      view = Oraculum.get 'Attach.View'

    afterEach ->
      view.__dispose()
      removeTestbed()

    dependsMixins Oraculum, 'Attach.ViewMixin',
      'EventedMethod.Mixin'

    it 'should read autoAttach, container, containerMethod at construction', ->
      view = Oraculum.get 'Attach.View'
      expect(view.mixinOptions.attach.auto).toBeTrue()
      expect(view.mixinOptions.attach.container).toBe 'container1'
      expect(view.mixinOptions.attach.containerMethod).toBe 'append'
      view.__dispose()
      view = Oraculum.get 'Attach.View',
        autoAttach: false
        container: 'container2'
        containerMethod: 'prepend'
      expect(view.mixinOptions.attach.auto).toBeFalse()
      expect(view.mixinOptions.attach.container).toBe 'container2'
      expect(view.mixinOptions.attach.containerMethod).toBe 'prepend'

    it 'should attach itself to an element automatically', ->
      view = Oraculum.get 'Attach.View', container: testbed
      expect(view.el.parentNode).toBe null
      view.render()
      expect(view.el.parentNode).toBe testbed

    it 'should attach itself to a selector automatically', ->
      view = Oraculum.get 'Attach.View', container: '#testbed'
      view.render()
      expect(view.el.parentNode).toBe testbed

    it 'should attach itself to a jQuery object automatically', ->
      return unless $
      view = Oraculum.get 'Attach.View', container: $('#testbed')
      view.render()
      expect(view.el.parentNode).toBe testbed

    it 'should use the given attach method', ->
      customContainerMethod = (container, el) ->
        p = container.parentNode
        p.insertBefore el, container.nextSibling
      containerMethod = if $ then 'after' else customContainerMethod
      view = Oraculum.get 'Attach.View', {container: testbed, containerMethod}
      view.render()
      expect(view.el).toBe testbed.nextSibling
      expect(view.el.parentNode).toBe testbed.parentNode

    it 'should consider autoRender, container and containerMethod properties', ->
      Oraculum.extend 'View', 'ConfiguredAttach.View', {
        mixinOptions:
          attach:
            container: '#testbed'
            containerMethod: if $ then 'before' else (container, el) ->
              p = container.parentNode
              p.insertBefore el, container
        render: -> (renderCalled = true) and this
      }, mixins: [
        'Attach.ViewMixin'
        'AutoRender.ViewMixin'
      ]
      view = Oraculum.get 'ConfiguredAttach.View'
      expect(renderCalled).toBeTrue()
      expect(view.el).toBe testbed.previousSibling
      expect(view.el.parentNode).toBe testbed.parentNode

    it 'should not attach itself more than once', ->
      spy = sinon.spy testbed, 'appendChild'
      view = Oraculum.get 'Attach.View', container: testbed
      view.render()
      view.render()
      expect(spy).toHaveBeenCalledOnce()

    it 'should not attach itself if autoAttach is false', ->
      Oraculum.extend 'View', 'NoAutoAttach1.View', {
        mixinOptions:
          attach:
            auto: false
            container: testbed
            containerMethod: if $ then 'before' else (container, el) ->
              p = container.parentNode
              p.insertBefore el, container
        render: -> (renderCalled = true) and this
      }, mixins: ['Attach.ViewMixin']

      Oraculum.extend 'View', 'NoAutoAttach2.View', {
        mixinOptions:
          attach:
            auto: false
            container: testbed
            containerMethod: if $ then 'before' else (container, el) ->
              p = container.parentNode
              p.insertBefore el, container
        render: -> (renderCalled = true) and this
      }, mixins: ['Attach.ViewMixin', 'AutoRender.ViewMixin']

      check = (view) ->
        parent = view.el.parentNode
        # In IE8 stuff will have documentFragment as parentNode.
        if parent
          expect(parent.nodeType).toBe 11
        else
          expect(parent).toBe null

      attach = sinon.spy Oraculum.mixins['Attach.ViewMixin'], 'attach'
      view1 = Oraculum.get 'NoAutoAttach1.View'
      expect(attach).not.toHaveBeenCalled()
      check view1
      attach.restore()

      attach = sinon.spy Oraculum.mixins['Attach.ViewMixin'], 'attach'
      view2 = Oraculum.get 'NoAutoAttach2.View'
      expect(attach).not.toHaveBeenCalled()
      check view2
      attach.restore()
