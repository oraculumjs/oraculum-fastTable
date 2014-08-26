require [
  'oraculum'
  'oraculum/views/mixins/auto-render'
], (Oraculum) ->
  'use strict'

  describe 'AutoRender.ViewMixin', ->
    view = null
    render = sinon.stub()

    Oraculum.extend 'View', 'AutoRender.View', {
      mixinOptions:
        autoRender: 'weirdTruthyValue'
      render: render
    }, mixins: ['AutoRender.ViewMixin']

    it 'should read autoRender at construction', ->
      view = Oraculum.get 'AutoRender.View'
      expect(view.mixinOptions.autoRender).toBe 'weirdTruthyValue'
      expect(render).not.toHaveBeenCalled()
      view.__dispose()

      view = Oraculum.get 'AutoRender.View', autoRender: false
      expect(view.mixinOptions.autoRender).toBe false
      expect(render).not.toHaveBeenCalled()
      view.__dispose()

      view = Oraculum.get 'AutoRender.View', autoRender: true
      expect(view.mixinOptions.autoRender).toBe true
      expect(render).toHaveBeenCalledOnce()
      view.__dispose()
