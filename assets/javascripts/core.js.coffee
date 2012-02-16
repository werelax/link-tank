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

Core = {}

class Sandbox
  create_channel: () ->

class PageSandbox extends Sandbox

class Page
  constructor: ->
    @_sandbox = new PageSandbox()
  load: (start_fn) ->
    Page.active = this
    init_fn(@_sandbox)
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

MainPage.load (page_sandbox) ->
  root = page_sandbox.get_root()
  root.html T['pages/main/root']

  # Channels
  search_chn = page_sandbox.create_channel()

  # Widgets
  search_box = new widgets.main.SearchBox search_chn, root: root.find('.e-search-box')

  # Page-wide event handling
  search_chn.on 'events:search', (query) ->
    # Do the search

# And the App, the entry point

LinkTank = new App()

LinkTank.load ->
  MainPage.load()


$ ->
  p1 = new Page('Test', 'test/:some')
  p2 = new Page('Tost', 'tost/:some')
  Router.add_route 'jarl', 'jarl', -> alert("jarl")
  Router.add_route 'jorl', 'jorl', -> console.log("jorl?")
  Router.start()
