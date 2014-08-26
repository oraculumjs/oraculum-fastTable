define [
  'oraculum'
], (Oraculum) ->
  'use strict'

  ###
  Make Evented Method
  ===================
  This function is the heart and soul of our dynamic AOP-based decoupling.
  This function will override any method of any object, replacing it with a
  method that executes a callback both before and after executing the original
  implementaion, and finally returning the result of the implementation
  back to the caller.

  It theoretically supports any eventing mechanism through the `emitter` and
  `trigger` options, as well as supporting the ability to `abort` the
  execution of the original implementation and change it's `result`.

  @param {Object} object The object that contains the targeted method.
  @param {String} method The targeted method name on `object`.
  @param {Object} emitter? The object that contains the event firing mechanism. (defaults to `object`)
  @param {String} trigger? The method name of the event firing method of `emitter`. (defaults to 'trigger')
  @param {String} eventPrefix? An optional string to prefix on the event name.
  ###

  Oraculum.define 'makeEventedMethod', (->

    return (object, methodName, emitter = object, trigger = 'trigger', eventPrefix = '') ->

      # Grab a handle to the original method.
      # Return immediately if it doesn't exist.
      original = object[methodName]
      return console?.warn? """
        Attempted to event undefined method #{method} of #{object}
      """ unless original

      # Don't do anything if the targeted method is already evented.
      return if original.evented

      # Grab a handle to the emitter's "trigger" method.
      fireEvent = emitter[trigger]

      # Do some sanity checks...
      throw new TypeError """
        Method #{methodName} does not exist on object
      """ unless typeof original is 'function'
      throw new TypeError """
        Method #{trigger} does not exist on emitter
      """ unless typeof fireEvent is 'function'

      # Ensure the event prefix ends with ':'
      eventPrefix ?= ':' if eventPrefix and not /:$/.test eventPrefix

      ###
      Create our new evented method.

      __fires__ `<emitter>#[eventPrefix:]<methodName>:before`

      __fires__ `<emitter>#[eventPrefix:]<methodName>:after`
      ###

      evented = object[methodName] = ->

        ###
        Create our `proxy` object. This object will be passed by reference
        through our events, allowing its properties to be mutated in memory
        by any listener that receives it.
        ###

        proxy =
          type: 'evented_proxy'
          abort: false
          result: undefined

        # Fire the `before` event, passing along our `proxy` object.
        fireEvent.call emitter, "#{eventPrefix}#{methodName}:before",
          arguments..., proxy, emitter, object

        ###
        Allow the implementation to be aborted, passing back whatever the
        current value of `proxy.result` is at that point.
        This allows the method's implementation to be completely bypassed and
        controlled by any arbitrary event listener.
        This can result in unexpected behavior if used ambiguously.
        Code carefully.
        ###

        return proxy.result if proxy.abort is true

        # Invoke the original method in the scope of the original `object`,
        # assigning its return value to `proxy.result`.
        proxy.result = original.apply object, arguments

        # Fire the `after` event, again passing along our `proxy` object.
        fireEvent.call emitter, "#{eventPrefix}#{methodName}:after",
          arguments..., proxy, emitter, object

        # Finally, return the result.
        return proxy.result

      # Mark the new method as evented
      evented.evented = true

      # And cache the original method
      evented.original = original

  ), singleton: true
