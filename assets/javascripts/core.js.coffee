# HERE:
#  (1) The App Core
#  (2) The Basic Sandbox
#  (3) The Routing controller and main State Machine

exports = Wrlx

Router = do ->
  routes = []

  class _Router extends Backbone.Router
    constructor: ->
      @route.apply(@, route) for route in routes

  add_route: (data...) ->
    routes.push(data)
  start: ->
    Wrlx.Core.router = new _Router
    Backbone.history.start()

class Channel
  subscribe: (type, fn, ctx) ->
    @events[type] ||= []
    @events[type].push({context: ctx, callback: fn || this})
  unsubscribe: (chn, fn) ->
    # pending
  publish: (type, args...) ->
    unless @events[type] then return false
    for subscriber in @events[type]
      subscriber.callback.apply(subscriber.context, args)
  constructor: ->
    @events = {}

Core =
  find: (selector, root=document) ->
    $(root).find(selector)
  ajax: (params...) ->
    $.ajax.apply($, params)
  get_page_root: ->
    Core.find('.e-page-root')

class App
  constructor: ->
    App._current = @
  load: (start_fn) ->
    $ -> start_fn(App.channel)

class Sandbox
  create_channel: -> new Channel

class PageSandbox extends Sandbox
  ajax: (params...) ->
    Core.ajax.apply(Core, params)
  get_root: ->
    Core.get_page_root()

class Page
  constructor: ->
    @_sandbox = new PageSandbox()
  load: (channel, load_params...) ->
    _.extend @_sandbox, channel
    @_onload.apply @, [@_sandbox].concat(load_params)
  onload: (start_fn) ->
    @_onload = ->
      Page.active = this
      start_fn(@_sandbox)
  unload: (stop_fn) ->
    stop_fn(@_sandbox)

exports['Core']    = Core
exports['Sandbox'] = Sandbox
exports['Page']    = Page

# PLAN:
# (1) Create class Channel based on the js article
# (2) Write the simplest possible thing

# What code do I want to write

MainPage = new Page(title: 'Link Tank', url: 'main')

MainPage.onload (page_sandbox) ->
  root = page_sandbox.get_root()
  root.html T['templates/pages/main/root']

  # Channels
  search_chn = page_sandbox.create_channel()

  # Widgets
  # search_box = new widgets.main.SearchBox search_chn, root: root.find('.e-search-box')

  # Page-wide event handling
  # search_chn.on 'events:search', (query) ->
    # Do the search

# LoginPage

LoginPage = new Page(title: 'LinkTank', url: '')

LoginPage.onload (page_sandbox) ->
  root = page_sandbox.get_root()
  root.html T['templates/pages/login/root']

  root.delegate '.e-login-button', 'click', ->
    page_sandbox.publish('login')

# And the App, the entry point

LinkTank = new App()

LinkTank.load (channel) ->
  body = Core.find('body')
  body.html(T['templates/layouts/fixed'])
  channel = new Channel()
  LoginPage.load(channel)
  channel.subscribe 'login', -> console.log("AKAN!")
  # MainPage.load()


#$ ->
  # p1 = new Page('Test', 'test/:some')
  # p2 = new Page('Tost', 'tost/:some')
  # Router.add_route 'jarl', 'jarl', -> alert("jarl")
  # Router.add_route 'jorl', 'jorl', -> console.log("jorl?")
  # Router.start()
