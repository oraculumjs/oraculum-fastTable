window.mockFactoryInstance = (stubs...) ->
  mockObject =
    __get: ->
    __factory: ->
    __getConstructor: ->

  mockObject[methodName] = sinon.stub() for methodName in stubs

  sinon.stub mockObject, '__get', (a...) -> a
  sinon.stub mockObject, '__getConstructor', (a...) -> a
  sinon.stub mockObject, '__factory', ->
    get: @__get, getConstructor: @__getConstructor

  return mockObject
