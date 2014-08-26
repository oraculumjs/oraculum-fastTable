define [
  'oraculum'
  'oraculum/libs'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  ###
  AutoFetch.ModelMixin
  ====================
  Automatically fetch a model as soon as it's created.
  ###

  Oraculum.defineMixin 'AutoFetch.ModelMixin',

    ###
    Mixin Options
    -------------
    Allow the autoFetch behavior to be configured on a definition.
    ###

    mixinOptions:
      autoFetch:
        fetch: true # Whether or not to fetch on init.
        fetchOptions: null # Any options to pass through to the fetch operation.

    ###
    Mixconfig
    ---------
    Allow autoFetch options to passed in the contructor options.

    @param {Boolean} autoFetch Set the `fetch` flag.
    @param {Object} fetchOptions Extend the default fetchOptions.
    ###

    mixconfig: ({autoFetch}, attrs, {autoFetch:fetch, fetchOptions} = {})->
      autoFetch.fetch = fetch if fetch?
      autoFetch.fetchOptions = _.extend {}, autoFetch.fetchOptions, fetchOptions

    ###
    Mixinitialize
    -------------
    Automatically fetch the model if we're still confugred to do so.
    ###

    mixinitialize: ->
      {fetch, fetchOptions} = @mixinOptions.autoFetch
      @fetch fetchOptions if fetch
