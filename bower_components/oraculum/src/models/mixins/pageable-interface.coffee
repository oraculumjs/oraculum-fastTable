define [
  'oraculum'
  'oraculum/libs'
  'oraculum/mixins/listener'
  'oraculum/mixins/disposable'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  # This mixin provides pageable behavior to a collection.
  # The semantics and defaults are based on the ElasticSearch page/size api
  stateModelName = '_PageableCollectionInterfaceState.Model'
  Oraculum.extend 'Model', stateModelName, {

    defaults:
      from:  0 # The current first-record offset.
      size: 10 # How many records to request.

      start: 0 # The zero-index offset of your paging API.
      total: 0 # The total number of records available.
      end:   0 # The last record offset relative to `start`.

      page:  1 # The numerical representation of of the current page.
      pages: 1 # The numerical representation of the last available page.

    # Add listeners for all attributes that would affect the outcome of our
    # reclaculation methods.
    mixinOptions:
      listen:
        'change:size change:start change:page this': '_calculateFrom'
        'change:size change:start change:from this': '_calculatePage'
        'change:size change:start change:total this': '_calculateEnd'

    _calculateFrom: ->
      page = @get 'page'
      size = @get 'size'
      start = @get 'start'
      from = ((page - 1) * size) + start
      @set { from }

    _calculatePage: ->
      from = @get 'from'
      size = @get 'size'
      start = @get 'start'
      relativeOffset = from - start
      page = 1 + Math.floor relativeOffset / size
      @set { page }

    _calculateEnd: ->
      size = @get 'size'
      start = @get 'start'
      total = @get 'total'
      end = total + start
      pages = Math.max 1, Math.ceil total / size
      @set { end, pages }

    parse: (response) ->
      response = _.clone response
      defaultKeys = _.chain(this).result('defaults').keys().value()
      _.each response, (value, key) ->
        return unless key in defaultKeys
        numericValue = parseInt value, 10
        throw new TypeError """
          Value for #{key}: #{value} is not a number.
        """ if _.isNaN numericValue
        response[key] = numericValue
      return response

  }, mixins: [
    'Listener.Mixin'
    'Disposable.Mixin'
  ]

  Oraculum.defineMixin 'PageableInterface.CollectionMixin',

    mixinOptions:
      pageable:
        from:  0 # The current first-record offset.
        size: 10 # How many records to request.
        start: 0 # The zero-index offset of your paging API.

    # Allow configuration overrides at construction
    mixconfig: ({pageable}, models, {start, from, size} = {}) ->
      pageable.start = start if start?
      pageable.from = from if from?
      pageable.size = size if size?

    mixinitialize: ->
      {start, from, size} = @mixinOptions.pageable
      @pageState = @__factory().get stateModelName,
        {start, from, size}, parse: true
      @on 'dispose', (target) =>
        return unless target is this
        @pageState.dispose()
        delete @pageState

    # State querying interface
    hasPrevious: ->
      page = @pageState.get 'page'
      return page > 1

    hasNext: ->
      page = @pageState.get 'page'
      pages = @pageState.get 'pages'
      return page < pages

    # Simplified paginating interface
    previous: ->
      page = @pageState.get 'page'
      @pageState.set 'page', --page if @hasPrevious()

    next: ->
      page = @pageState.get 'page'
      @pageState.set 'page', ++page if @hasNext()

    jumpTo: (page) ->
      page = parseInt page, 10
      pages = @pageState.get 'pages'
      return unless page >= 1 and page <= pages
      @pageState.set { page }

    jumpToFirst: -> @jumpTo 1
    jumpToLast: -> @jumpTo @pageState.get 'pages'

    # Config/reconfig interface
    setPageSize: (size) -> @pageState.set { size }
    setPageStart: (start) -> @pageState.set { start }
