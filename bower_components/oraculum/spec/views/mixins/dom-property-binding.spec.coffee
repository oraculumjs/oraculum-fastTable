require [
  'oraculum'
  'oraculum/mixins/disposable'
  'oraculum/views/mixins/html-templating'
  'oraculum/views/mixins/dom-property-binding'
], (Oraculum) ->
  'use strict'

  describe 'DOMPropertyBinding.ViewMixin', ->
    view = null
    model = null
    collection = null

    Oraculum.extend 'View', 'DOMPropertyBinding.View', {
      mixinOptions:
        domPropertyBinding: {'placeholder'}
    }, mixins: [
      'Disposable.Mixin'
      'HTMLTemplating.ViewMixin'
      'DOMPropertyBinding.ViewMixin'
    ]

    afterEach ->
      view?.__dispose()

    dependsMixins Oraculum, 'DOMPropertyBinding.ViewMixin',
      'Evented.Mixin'
      'EventedMethod.Mixin'

    it 'should read placeholder at construction', ->
      view = Oraculum.get 'DOMPropertyBinding.View'
      expect(view.mixinOptions.domPropertyBinding.placeholder).toBe 'placeholder'
      view.__dispose()
      view = Oraculum.get 'DOMPropertyBinding.View', placeholder: 'somethingElse'
      expect(view.mixinOptions.domPropertyBinding.placeholder).toBe 'somethingElse'

    describe 'Model binding', ->

      beforeEach ->
        model = Oraculum.get 'Model', {'attribute'}

      afterEach ->
        model.__dispose()

      it 'should bind model attributes to an element', ->
        template = '''<div
          class="test"
          data-prop="model"
          data-prop-attr="attribute"
        />'''
        view = Oraculum.get 'DOMPropertyBinding.View', {model, template}
        view.render()
        elem = view.$ '.test'
        expect(elem.text()).toBe 'attribute'
        model.set 'attribute', 'somethingElse'
        expect(elem.text()).toBe 'somethingElse'

      it 'should allow alternate dom manipulation methods', ->
        template = '''<div
          class="test"
          data-prop="model"
          data-prop-attr="attribute"
          data-prop-method="addClass"
        />'''
        view = Oraculum.get 'DOMPropertyBinding.View', {model, template}
        view.render()
        elem = view.$ '.test'
        expect(elem).toHaveClass 'attribute'
        model.set 'attribute', 'somethingElse'
        expect(elem).toHaveClass 'somethingElse'

      it 'should respect custom event listeners', ->
        template = '''<div
          class="test"
          data-prop="model"
          data-prop-attr="attribute"
          data-prop-events="customEvent1 customEvent2"
        />'''
        view = Oraculum.get 'DOMPropertyBinding.View', {model, template}
        view.render()
        elem = view.$ '.test'
        expect(elem.text()).toBe 'attribute'
        model.set 'attribute', 'somethingElse'
        expect(elem.text()).toBe 'attribute'
        model.trigger 'customEvent1'
        expect(elem.text()).toBe 'somethingElse'
        model.set 'attribute', 'somethingNew'
        expect(elem.text()).toBe 'somethingElse'
        model.trigger 'customEvent2'
        expect(elem.text()).toBe 'somethingNew'

      it 'should allow empty (no) event listeners', ->
        template = '''<div
          class="test"
          data-prop="model"
          data-prop-attr="attribute"
          data-prop-events=""
        />'''
        view = Oraculum.get 'DOMPropertyBinding.View', {model, template}
        view.render()
        elem = view.$ '.test'
        expect(elem.text()).toBe 'attribute'
        model.set 'attribute', 'somethingElse'
        expect(elem.text()).toBe 'attribute'
        model.set 'attribute', 'somethingNew'
        expect(elem.text()).toBe 'attribute'

    describe 'Collection binding', ->

      beforeEach ->
        collection = Oraculum.get 'Collection', [
          {id: 'one'}
          {id: 'two'}
          {id: 'three'}
        ]

      afterEach ->
        collection.__dispose()

      it 'should bind collection attributes to an element', ->
        template = '''<div
          class="test"
          data-prop="collection"
          data-prop-attr="length"
        />'''
        view = Oraculum.get 'DOMPropertyBinding.View', {collection, template}
        view.render()
        elem = view.$ '.test'
        expect(elem.text()).toBe collection.length.toString()
        collection.reset()
        expect(elem.text()).toBe collection.length.toString()

      it 'should bind collection model attributes to an element', ->
        template = '''<div
          class="test"
          data-prop="collection"
          data-prop-attr="models.0.id"
        />'''
        model = collection.models[0]
        view = Oraculum.get 'DOMPropertyBinding.View', {collection, template}
        view.render()
        elem = view.$ '.test'
        expect(elem.text()).toBe model.id
        collection.reset [{id:'four'}]
        model = collection.models[0]
        expect(elem.text()).toBe model.id

    describe 'Object binding', ->

      it 'should be able to resolve a property on an object', ->
        template = '''<div
          class="test"
          data-prop="someObject"
          data-prop-attr="some.property"
        />'''
        someObject = some: {'property'}
        view = Oraculum.get 'DOMPropertyBinding.View', {template}
        view.someObject = someObject
        view.render()
        elem = view.$ '.test'
        expect(elem.text()).toBe 'property'
        someObject.some.property = 'otherProperty'
        view.render()
        elem = view.$ '.test'
        expect(elem.text()).toBe 'otherProperty'

      it 'should be able to resolve a function on an object', ->
        template = '''<div
          class="test"
          data-prop="someObject"
          data-prop-attr="some.function"
        />'''
        someObject = some: function: -> 'result'
        view = Oraculum.get 'DOMPropertyBinding.View', {template}
        view.someObject = someObject
        view.render()
        elem = view.$ '.test'
        expect(elem.text()).toBe 'result'
        someObject.some.function = -> 'otherResult'
        view.render()
        elem = view.$ '.test'
        expect(elem.text()).toBe 'otherResult'

      it 'should be able to resolve a property on an array', ->
        template = '''<div
          class="test"
          data-prop="someArray"
          data-prop-attr="1.2"
        />'''
        someArray = [null,[null,null,'value',null],null]
        view = Oraculum.get 'DOMPropertyBinding.View', {template}
        view.someArray = someArray
        view.render()
        elem = view.$ '.test'
        expect(elem.text()).toBe 'value'
        someArray[1][2] = 'otherValue'
        view.render()
        elem = view.$ '.test'
        expect(elem.text()).toBe 'otherValue'

    describe 'Error conditions', ->

      it 'should throw an error if a bound property does not exist', ->
        template = '''<div
          class="test"
          data-prop="nonexistant"
          data-prop-attr="nonexistant"
        />'''
        view = Oraculum.get 'DOMPropertyBinding.View', {template}
        expect(-> view.render()).toThrow()

      it 'should render a placeholder when a property\'s attribute is nullish', ->
        template = '''<div
          class="test"
          data-prop="someObject"
          data-prop-attr="nonexistant"
        />'''
        view = Oraculum.get 'DOMPropertyBinding.View', {template}
        view.someObject = {}
        view.render()
        elem = view.$ '.test'
        expect(elem.text()).toBe 'placeholder'
        view.mixinOptions.domPropertyBinding.placeholder = 'otherPlaceholder'
        view.render()
        elem = view.$ '.test'
        expect(elem.text()).toBe 'otherPlaceholder'
