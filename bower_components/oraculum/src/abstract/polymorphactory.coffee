define [
  'oraculum'
], (Oraculum) ->
  'use strict'

  ###
  PolymorPhactory
  ===============
  The purpose of `PolymorPhactory` is to provide a simple mechanism with which
  the factory can resolve instances of different definitions based on some
  arbitrary condition.
  A common use case for this is for resolving different view definitions for
  models if disparate types in a collection.
  ###

  Oraculum.define 'PolymorPhactory', class PolymorPhactory

    ###
    Type Map
    --------
    `typeMap` provides a lookup index for your variable definitions where
    the value will be a definition available in the factory.
    In the example above, it may map model definition names to view
    definition names, like so:

    @type {Object}
    ###

    #### Example configuration ###
    # ```coffeescript
    # typeMap:
    #   'Some.Model': 'SomeModel.View'
    #   'Another.Model': 'AnotherModel.View'
    # ```

    typeMap: null

    ###
    Get Type String
    ---------------
    This method must be overridden to return a value that will be used as an
    index key on `@typeMap`.
    It receives any arguments passed to the constructor.
    Continuing our example, a common implementation may look like this:

    ```coffeescript
    getTypeString: ({model}) -> model.__type()
    ````

    @return {String} Key to use to lookup value of `@typeMap`
    ###

    getTypeString: -> throw new Error '''
      PolymorPhactory::getTypeString must be overridden
    '''

    ###
    Constructor
    -----------
    The constructor will return an instance of whatever definition is mapped
    to the return value of `@getTypeString` in `@typeMap`, passing through
    any constructor arguments to the factory getter.

    @return {Object} Instance of definition reolved by `@getTypeString`
    ###

    constructor: ->
      typeString = @getTypeString arguments...
      typeString = @typeMap[typeString] if @typeMap?[typeString]?
      return @__factory().get typeString, arguments...
