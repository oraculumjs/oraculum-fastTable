require [
  'oraculum'
  'oraculum/libs'
  'oraculum/application/controller'
  'oraculum/mixins/disposable'
  'oraculum/views/mixins/layout'
  'oraculum/mixins/callback-provider'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'
  Backbone = Oraculum.get 'Backbone'

  provideCallback = Oraculum.mixins['CallbackProvider.Mixin'].provideCallback
  removeCallbacks = Oraculum.mixins['CallbackProvider.Mixin'].removeCallbacks

  describe 'Layout', ->
    # Initialize shared variables
    layout = testController = router = null

    Oraculum.extend 'View', 'Layout.View', {
      el: document.body
      mixinOptions:
        disposable:
          disposeAll: true
    }, mixins: [
      'Layout.ViewMixin'
      'Disposable.Mixin'
    ]

    template = -> -> '<div id="test1"></div><div id="test2"></div>'
    template5 = -> -> '<div id="test1"></div><div id="test5"></div>'

    preventDefault = (event) -> event.preventDefault()

    createLink = (attributes) ->
      attributes = _.extend {}, attributes
      # Yes, this is ugly. We’re doing it because IE8-10 reports an incorrect
      # protocol if the href attribute is set programatically.
      if attributes.href?
        div = document.createElement 'div'
        div.innerHTML = "<a href='#{attributes.href}'>Hello World</a>"
        link = div.firstChild
        attributes = _.omit attributes, 'href'
      else
        link = document.createElement 'a'
      link.setAttribute key, value for key, value of attributes
      return link

    appendClickRemove = (element) ->
      document.body.appendChild element
      $(element).click()
      document.body.removeChild element

    expectWasRouted = (linkAttributes) ->
      stub = sinon.stub()
      provideCallback 'router:route', stub
      appendClickRemove createLink linkAttributes
      expect(stub).toHaveBeenCalledOnce()
      [passedPath] = stub.firstCall.args
      expect(passedPath).toEqual url: linkAttributes.href
      removeCallbacks(['router:route'])
      return stub

    expectWasNotRouted = (linkAttributes) ->
      spy = sinon.spy()
      provideCallback 'router:route', spy
      appendClickRemove createLink linkAttributes
      expect(spy).not.toHaveBeenCalled()
      removeCallbacks(['router:route'])
      return spy

    beforeEach ->
      # Create the layout
      layout = Oraculum.get 'Layout.View',
        title: 'Test Site Title'

      # Create a test controller
      testController = Oraculum.get 'Controller'
      testController.view = Oraculum.get 'View'
      testController.title = 'Test Controller Title'

    afterEach ->
      testController.dispose()
      layout.dispose()

    it 'should have el, $el and $ props / methods', ->
      expect(layout.el).toBe document.body
      expect(layout.$el).toBeInstanceOf $

    it 'should set the document title', ->
      spy = sinon.spy()
      layout.listenTo Backbone, '!adjustTitle', spy
      layout.publishEvent '!adjustTitle', testController.title
      expect(document.title).toContain layout.mixinOptions.layout.title
      expect(document.title).toContain testController.title
      expect(spy).toHaveBeenCalledWith testController.title

    # Default routing options
    # -----------------------

    it 'should route clicks on internal links', ->
      expectWasRouted href: '/internal/link'

    it 'should correctly pass the query string', ->
      path = '/internal/link'
      query = 'foo=bar&baz=qux'

      stub = sinon.spy()
      provideCallback 'router:route', stub
      linkAttributes = href: "#{path}?#{query}"
      appendClickRemove createLink linkAttributes
      expect(stub).toHaveBeenCalledOnce()
      [passedPath] = stub.firstCall.args
      expect(passedPath).toEqual url: linkAttributes.href
      removeCallbacks(['router:route'])

    it 'should not route links without href attributes', ->
      expectWasNotRouted name: 'foo'

    it 'should not route links with empty href', ->
      expectWasNotRouted href: ''

    it 'should not route links to document fragments', ->
      expectWasNotRouted href: '#foo'

    it 'should not route links to javascript:void(0);', ->
      expectWasNotRouted href: 'javascript:void(0);'
      expectWasNotRouted href: 'javascript: void(0);'
      expectWasNotRouted href: 'javascript:   void(-)'
      expectWasNotRouted href: 'javascript:       void(sdjfhsdlkjflkdsjf)'

    it 'should not route links with a noscript class', ->
      expectWasNotRouted href: '/foo', class: 'noscript'

    it 'should not route rel=external links', ->
      expectWasNotRouted href: '/foo', rel: 'external'

    it 'should not route target=blank links', ->
      expectWasNotRouted href: '/foo', target: '_blank'

    it 'should not route non-http(s) links', ->
      expectWasNotRouted href: 'mailto:a@a.com'
      expectWasNotRouted href: 'javascript:1+1'
      expectWasNotRouted href: 'tel:1488'

    it 'should not route clicks on external links', ->
      old = window.open
      window.open = sinon.stub()
      expectWasNotRouted href: 'http://example.com/'
      expectWasNotRouted href: 'https://example.com/'
      expect(window.open).not.toHaveBeenCalled()
      window.open = old

    it 'should route clicks on elements with the “go-to” class', ->
      stub = sinon.stub()
      provideCallback 'router:route', stub
      path = '/internal/link'
      span = document.createElement 'span'
      span.className = 'go-to'
      span.setAttribute 'data-href', path
      appendClickRemove span
      expect(stub).toHaveBeenCalledOnce()
      passedPath = stub.firstCall.args[0]
      expect(passedPath).toEqual url: path
      removeCallbacks(['router:route'])

    # With custom external checks
    # ---------------------------

    it 'custom isExternalLink receives link properties', ->
      stub = sinon.stub().returns true
      layout.isExternalLink = stub
      expectWasNotRouted href: 'http://www.example.org:1234/foo?bar=1#baz', target: "_blank", rel: "external"

      expect(stub).toHaveBeenCalledOnce()
      link = stub.lastCall.args[0]
      expect(link.target).toBe "_blank"
      expect(link.rel).toBe "external"
      expect(link.hash).toBe "#baz"
      expect(link.pathname.replace(/^\//, '')).toBe "foo"
      expect(link.host).toBe "www.example.org:1234"

    it 'custom isExternalLink should not route if true', ->
      layout.isExternalLink = -> true
      expectWasNotRouted href: '/foo'

    it 'custom isExternalLink should route if false', ->
      layout.isExternalLink = -> false
      expectWasRouted href: '/foo', rel: "external"

    # With custom routing options
    # ---------------------------

    it 'routeLinks=false should NOT route clicks on internal links', ->
      layout.dispose()
      layout = Oraculum.get 'Layout.View',
        routeLinks: false
        title: ''
      expectWasNotRouted href: '/internal/link'

    it 'openExternalToBlank=true should open external links in a new tab', ->
      old = window.open

      window.open = sinon.stub()
      layout.dispose()
      layout = Oraculum.get 'Layout.View',
        openExternalToBlank: true
        title: ''
      expectWasNotRouted href: 'http://www.example.org/'
      expect(window.open).toHaveBeenCalled()

      window.open = sinon.stub()
      layout.dispose()
      layout = Oraculum.get 'Layout.View',
        openExternalToBlank: true
        title: ''
      expectWasNotRouted href: '/foo', rel: "external"
      expect(window.open).toHaveBeenCalled()

      window.open = old

    it 'skipRouting=false should route links with a noscript class', ->
      layout.dispose()
      layout = Oraculum.get 'Layout.View',
        skipRouting: false
        title: ''
      expectWasRouted href: '/foo', class: 'noscript'

    it 'skipRouting=function should decide whether to route', ->
      path = '/foo'
      stub = sinon.stub().returns false
      layout.dispose()
      layout = Oraculum.get 'Layout.View',
        skipRouting: stub
        title: ''
      expectWasNotRouted href: path
      expect(stub).toHaveBeenCalledOnce()
      args = stub.lastCall.args
      expect(args[0]).toBe path
      expect(args[1]).toBeObject()
      expect(args[1].nodeName).toBe 'A'

      stub = sinon.stub().returns true
      layout.dispose()
      layout = Oraculum.get 'Layout.View',
        skipRouting: stub
        title: ''
      expectWasRouted href: path
      expect(stub).toHaveBeenCalledOnce()
      expect(args[0]).toBe path
      expect(args[1]).toBeObject()
      expect(args[1].nodeName).toBe 'A'

    # Regions
    # -------

    it 'should allow for views to register regions', ->
      Oraculum.extend 'View', 'Test1Layout.View', {
        mixinOptions:
          regions:
            'view-region1': ''
            'test1': '#test1'
            'test2': '#test2'
      }, mixins: [
        'Disposable.Mixin'
        'RegionPublisher.ViewMixin'
      ]

      Oraculum.extend 'View', 'Test2Layout.View', {
        mixinOptions:
          regions:
            'view-region2': ''
            'test3': '#test1'
            'test4': '#test2'
      }, mixins: [
        'Disposable.Mixin'
        'RegionPublisher.ViewMixin'
      ]

      spy = sinon.spy(layout, 'registerGlobalRegion')
      instance1 = Oraculum.get 'Test1Layout.View'
      expect(spy).toHaveBeenCalledWith instance1, 'view-region1', ''
      expect(spy).toHaveBeenCalledWith instance1, 'test1', '#test1'
      expect(spy).toHaveBeenCalledWith instance1, 'test2', '#test2'
      expect(layout.globalRegions).toEqual [
        {instance: instance1, name: 'test2', selector: '#test2'}
        {instance: instance1, name: 'test1', selector: '#test1'}
        {instance: instance1, name: 'view-region1', selector: ''}
      ]

      instance2 = Oraculum.get 'Test2Layout.View'
      expect(spy).toHaveBeenCalledWith instance2, 'view-region2', ''
      expect(spy).toHaveBeenCalledWith instance2, 'test3', '#test1'
      expect(spy).toHaveBeenCalledWith instance2, 'test4', '#test2'
      expect(layout.globalRegions).toEqual [
        {instance: instance2, name: 'test4', selector: '#test2'}
        {instance: instance2, name: 'test3', selector: '#test1'}
        {instance: instance2, name: 'view-region2', selector: ''}
        {instance: instance1, name: 'test2', selector: '#test2'}
        {instance: instance1, name: 'test1', selector: '#test1'}
        {instance: instance1, name: 'view-region1', selector: ''}
      ]

      instance1.dispose()
      instance2.dispose()

    it 'should allow for itself to register regions', ->
      layout.dispose()
      Oraculum.extend 'View', 'RegionalLayout.View', {
        mixinOptions:
          regions:
            'view-region1': ''
            'test1': '#test1'
            'test2': '#test2'
      }, mixins: [
        'Layout.ViewMixin'
        'Disposable.Mixin'
      ]
      regional = Oraculum.get 'RegionalLayout.View'
      expect(regional.globalRegions).toEqual [
        {instance: regional, name: 'test2', selector: '#test2'}
        {instance: regional, name: 'test1', selector: '#test1'}
        {instance: regional, name: 'view-region1', selector: ''}
      ]
      regional.dispose()

    it 'should dispose of regions when a view is disposed', ->
      Oraculum.extend 'View', 'DisposeRegion.View', {
        mixinOptions:
          regions:
            'test0': ''
            'test1': '#test1'
            'test2': '#test2'
      }, mixins: [
        'Disposable.Mixin'
        'RegionPublisher.ViewMixin'
      ]
      instance = Oraculum.get 'DisposeRegion.View'
      instance.dispose()
      expect(layout.globalRegions).toEqual []

    it 'should only dispose of regions a view registered when it is disposed', ->
      Oraculum.extend 'View', 'Test1Layout.View', {
        mixinOptions:
          regions:
            'test1': '#test1'
            'test2': '#test2'
      }, {
        override: true
        mixins: [
          'Disposable.Mixin'
          'RegionPublisher.ViewMixin'
        ]
      }

      Oraculum.extend 'View', 'Test2Layout.View', {
        mixinOptions:
          regions:
            'test3': '#test1'
            'test4': '#test2'
            'test5': ''
      }, {
        override: true
        mixins: [
          'Disposable.Mixin'
          'RegionPublisher.ViewMixin'
        ]
      }

      instance1 = Oraculum.get 'Test1Layout.View'
      instance2 = Oraculum.get 'Test2Layout.View'
      instance2.dispose()
      expect(layout.globalRegions).toEqual [
        {instance: instance1, name: 'test2', selector: '#test2'}
        {instance: instance1, name: 'test1', selector: '#test1'}
      ]
      instance1.dispose()

    # it 'should allow for views to be applied to regions', ->
    #   view1 = class Test1View extends View
    #     autoRender: true
    #     getTemplateFunction: template
    #     regions:
    #       test0: ''
    #       test1: '#test1'
    #       test2: '#test2'

    #   view2 = class Test2View extends View
    #     autoRender: true
    #     getTemplateFunction: -> # Do nothing

    #   instance1 = new Test1View()
    #   instance2 = new Test2View {region: 'test2'}
    #   instance3 = new Test2View {region: 'test0'}

    #   if $
    #     expect(instance2.container.attr('id')).toBe 'test2'
    #     expect(instance3.container).toBe instance1.$el
    #   else
    #     expect(instance2.container.id).toBe 'test2'
    #     expect(instance3.container).toBe instance1.el

    #   instance1.dispose()
    #   instance2.dispose()

    # it 'should apply regions in the order they were registered', ->
    #   view1 = class Test1View extends View
    #     autoRender: true
    #     getTemplateFunction: template
    #     regions:
    #       'test1': '#test1'
    #       'test2': '#test2'

    #   view2 = class Test2View extends View
    #     autoRender: true
    #     getTemplateFunction: template5
    #     regions:
    #       'test1': '#test1'
    #       'test2': '#test5'

    #   view3 = class Test3View extends View
    #     autoRender: true
    #     getTemplateFunction: -> # Do nothing

    #   instance1 = new Test1View()
    #   instance2 = new Test2View()
    #   instance3 = new Test3View {region: 'test2'}
    #   if $
    #     expect(instance3.container.attr('id')).toBe 'test5'
    #   else
    #     expect(instance3.container.id).toBe 'test5'

    #   instance1.dispose()
    #   instance2.dispose()
    #   instance3.dispose()

    # it 'should only apply regions from non-stale views', ->
    #   view1 = class Test1View extends View
    #     autoRender: true
    #     getTemplateFunction: template
    #     regions:
    #       'test1': '#test1'
    #       'test2': '#test2'

    #   view2 = class Test2View extends View
    #     autoRender: true
    #     getTemplateFunction: template
    #     regions:
    #       'test1': '#test1'
    #       'test2': '#test5'

    #   view3 = class Test3View extends View
    #     autoRender: true
    #     getTemplateFunction: -> # Do nothing

    #   instance1 = new Test1View()
    #   instance2 = new Test2View()
    #   instance2.stale = true
    #   instance3 = new Test3View {region: 'test2'}
    #   if $
    #     expect(instance3.container.attr('id')).toBe 'test2'
    #   else
    #     expect(instance3.container.id).toBe 'test2'

    #   instance1.dispose()
    #   instance2.dispose()
    #   instance3.dispose()

    # it 'should dispose itself correctly', ->
    #   spy1 = sinon.spy()
    #   layout.subscribeEvent 'foo', spy1

    #   spy2 = sinon.spy()
    #   layout.delegateEvents 'click #testbed': spy2

    #   expect(layout.dispose).toBeFunction()
    #   layout.dispose()

    #   expect(layout.disposed).toBe true
    #   if Object.isFrozen
    #     expect(Object.isFrozen(layout)).toBe true

    #   mediator.publish 'foo'
    #   window.clickOnElement document.querySelector('#testbed')

    #   # It should unsubscribe from events
    #   expect(spy1).not.toHaveBeenCalled()
    #   expect(spy2).not.toHaveBeenCalled()

    # it 'should be extendable', ->
    #   expect(Layout.extend).toBeFunction

    #   DerivedLayout = Layout.extend()
    #   derivedLayout = new DerivedLayout()
    #   expect(derivedLayout).to.be.a Layout

    #   derivedLayout.dispose()
