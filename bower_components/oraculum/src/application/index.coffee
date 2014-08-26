define [
  'oraculum'
  'oraculum/mixins/pub-sub'
  'oraculum/mixins/freezable'
  'oraculum/mixins/disposable'
  'oraculum/application/router'
  'oraculum/application/composer'
  'oraculum/application/dispatcher'
], (Oraculum) ->
  'use strict'

  ###
  Application
  ===========
  The role of the `Application` is to act as the entrypoint/primary bootstrapper
  for our application, stitching together our `Router`, `Dispatcher`, `Layout`,
  and `Composer`.

  @see application/router.coffee
  @see application/composer.coffee
  @see application/dispatcher.coffee
  ###

  Oraculum.define 'Application', (class Application

    ###
    Title
    -----
    Site-wide title that is mapped to HTML `title` tag.

    @type {String}
    ###

    title: ''

    ###
    Started
    -------
    Track whether or not the `Application` has been started. This value is set
    to `true` upon invoking `@start`.

    @type {Boolean}
    ###

    started: false

    ###
    Core Object Instantiation
    -------------------------
    The application instantiates three **core modules**:
    ###

    ###
    A `View` that supports the `Layout.ViewMixin` interface.

    @see views/mixins/layout.coffee
    @see http://backbonejs.org/#View

    @type {View}
    ###

    layout: null

    ###
    A global `Router`.

    @type {Router}
    ###

    router: null

    ###
    A global `Composer`.

    @type {Composer}
    ###

    composer: null

    ###
    And a global `Dispatcher`.

    @type {Dispatcher}
    ###

    dispatcher: null

    ###
    Constructor
    -----------
    Initializes core components.

    @param {Object} options? Any options to be passed to our initializers.
    ###

    constructor: (options = {}) ->

      # Register all of our `Route`s, passing through our `options`.
      @initRouter options.routes, options

      # Dispatcher listens for routing events and initialises controllers.
      @initDispatcher options

      # Layout listens for click events & delegates internal links to router.
      @initLayout options

      # Composer grants the ability for views and stuff to be persisted.
      @initComposer options

      # Invoke our initialize method
      @initialize.apply this, arguments

      # Start the application.
      @start()

    ###
    Mixin Options
    -------------
    Automatically freeze this object after its construction and instruct the
    `Disposable.Mixin` to dispose all of our properties upon disposal.

    @see mixins/freezable.coffee
    @see mixins/disposable.coffee
    ###

    mixinOptions:
      freeze: true
      disposable:
        disposeAll: true

    ###
    Initialize Router
    -----------------
    Creates the global `Router`, passing it all of our `options`.
    Invokes the `routes` function, if available, passing through the `Router`s
    `match` method, creating `Route`s for each specification.
    Resolves `options.router` to a factory definition to use as the `Router`.
    If `options.router` is not defined, it will default to `'Router'`.

    @see application/route.coffee
    @see application/router.coffee

    @param {Function} routes? The `routes` function.
    @param {Object} object? Any options to pass to the `Router`'s constructor.
    ###

    initRouter: (routes, options = {}) ->
      # Save the reference for testing introspection only.
      # Modules should communicate with each other via **publish/subscribe**.
      options.router ?= 'Router'
      @router = if _.isString options.router
      then @__factory().get options.router, options
      else new options.router options

      # Register any provided routes.
      routes? @router.match


    ###
    Initialize Dispatcher
    ---------------------
    Creates the global `Dispatcher`, passing it all of our `options`.
    Resolves `options.dispatcher` to a factory definition to use as the
    `Dispatcher`.
    If `options.dispatcher` is not defined, it will default to `'Dispatcher'`.

    @see application/dispatcher.coffee

    @param {Object} object? Any options to pass to the `Dispatcher`'s constructor.
    ###

    initDispatcher: (options = {}) ->
      options.dispatcher ?= 'Dispatcher'
      @dispatcher = if _.isString options.dispatcher
      then @__factory().get options.dispatcher, options
      else new options.dispatcher options

    ###
    Initialize Layout
    -----------------
    Creates the global `Layout` `View`, passing it all of our `options`.
    Assigns `options.title` as `@title` if `options.title` is not defined.
    Resolves `options.layout` to a factory definition to use as the `Layout`.
    If `options.layout` is not defined, it will throw.

    @see views/mixins/layout.coffee
    @see http://backbonejs.org/#View

    @param {Object} object? Any options to pass to the `Layout`'s constructor.
    ###

    initLayout: (options = {}) ->
      options.title ?= @title
      @layout = if _.isString options.layout
      then @__factory().get options.layout, options
      else new options.layout options

    ###
    Initialize Composer
    ---------------------
    Creates the global `Composer`, passing it all of our `options`.
    Resolves `options.composer` to a factory definition to use as the
    `Composer`.
    If `options.composer` is not defined, it will default to `'Composer'`.

    @see application/composer.coffee

    @param {Object} object? Any options to pass to the `Composer`'s constructor.
    ###

    initComposer: (options = {}) ->
      options.composer ?= 'Composer'
      @composer = if _.isString options.composer
      then @__factory().get options.composer, options
      else new options.composer options

    ###
    Initialize
    ----------
    We provide a basic `initialize` method to perform the most common use case
    implementation while keeping this logic out of `constructor` so that an
    extending definition can override `initialize`, taking control over the
    `@start` method's invocation.
    Throws if invoked after `@started` is set to `true`.
    ###

    initialize: ->
      # Check if app is already started.
      throw new Error '''
        Application#initialize: App was already started
      ''' if @started

    ###
    Start
    -----
    Starts the `Router`'s history tracking, setting forth a chain of events that
    should lead to `History` reading the URL state, causing the `Router` notify
    the `Dispatcher` of a matched `Route`, culminating in the creation of a
    `Controller` and the execution of the `Route`'s prescribed action.

    @see application/route.coffee
    @see application/router.coffee
    @see application/history.coffee
    @see application/controller.coffee
    @see application/dispatcher.coffee
    ###
    start: ->
      # After registering the routes, start **Backbone.history**.
      @router.startHistory()

      # Mark app as initialized.
      @started = true

  ), {
    singleton: true
    mixins: [
      'PubSub.Mixin'
      'Disposable.Mixin'
      'Freezable.Mixin'
    ]
  }
