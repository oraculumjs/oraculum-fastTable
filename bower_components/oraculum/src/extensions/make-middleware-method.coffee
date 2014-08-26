define [
  'oraculum'
], (Oraculum) ->
  'use strict'

  ###
  Make Middleware Method
  ======================
  `makeMiddlewareMethod` is essentially the same as `makeEventedMethod`, however
  it allows the original method to be deferred, and fires an additional event to
  notify any listeners that the method has been deferred.

  @see extensions/make-evented-method.coffee

  @param {Object} object The object that contains the targeted method.
  @param {String} method The targeted method name on `object`.
  @param {Object} emitter? The object that contains the event firing mechanism. (defaults to `object`)
  @param {String} trigger? The method name of the event firing method of `emitter`. (defaults to 'trigger')
  @param {String} eventPrefix? An optional string to prefix on the event name.
  ###

  Oraculum.define 'makeMiddlewareMethod', (->

    return (object, methodName, emitter = object, trigger = 'trigger', eventPrefix = '') ->

      # Grab a handle to the original method.
      # Return immediately if it doesn't exist.
      original = object[methodName]
      return console?.warn? """
        Attempted to event undefined method #{methodName} of #{object}
      """ unless original

      # Don't do anything if the targeted method is already middleware.
      return if original.middleware

      # Grab a handle to the emitter's "trigger" method.
      fireEvent = emitter[trigger]

      # Do some sanity checks...
      throw new TypeError """
        Method #{methodName} does not exist on object
      """ unless typeof original is 'function'
      throw new TypeError """
        Method #{trigger} does not exist on emitter
      """ unless typeof fireEvent is 'function'

      # Modify the event prefix to ensure it ends with ':'
      eventPrefix ?= ':' if eventPrefix and not /:$/.test eventPrefix

      ###
      Create our new middleware method.

      __fires__ `<emitter>#[eventPrefix:]<methodName>:middleware:before`

      __fires__ `<emitter>#[eventPrefix:]<methodName>:middleware:after`
      ###

      middleware = object[methodName] = (args...) ->

        ###
        Create our `proxy` object. This object will be passed by reference
        through our events, allowing its properties to be mutated in memory
        by any listener that receives it.
        ###

        proxy =
          type: 'middleware_proxy'
          wait: false
          abort: false
          result: undefined

        # Fire the initial event, passing along our proxy
        fireEvent.call emitter, "#{eventPrefix}:#{methodName}:middleware:before",
          args..., proxy, emitter, object

        ###
        Allow the implementation to be aborted, passing back whatever the
        current value of `proxy.result` is at that point.
        This allows the method's implementation to be completely bypassed and
        controlled by any arbitrary event listener.
        This can result in unexpected behavior if used incorrectly or ambiguously.
        Code carefully.
        ###

        return proxy.result if proxy.abort is true

        # Create a callback to invoke our original implementation.
        resolve = ->

          # Invoke the original method in the scope of the original `object`,
          # assigning its return value to `proxy.result`.
          proxy.result = original.call object, args...

          # Fire the `after` event, again passing along our `proxy` object.
          fireEvent.call emitter, "#{eventPrefix}:#{methodName}:middleware:after",
            args..., proxy, emitter, object

        # If we're waiting, create a promise and pass it through the `proxy`.
        if proxy.wait is true
          proxy.dfd = new $.Deferred()
          proxy.promise = proxy.dfd.promise()
          proxy.promise.then resolve
          fireEvent.call emitter, "#{eventPrefix}:#{methodName}:middleware:defer",
            args..., proxy, emitter, object

        # Otherwise, simply invoke our resolver
        else resolve()

        # Finally, return the result.
        return proxy.result

      # Mark the new method as middleware
      middleware.middleware = true

      # And cache the original method
      middleware.original = original

  ), singleton: true
