exports = (this.W ||= {})

Router = do ->
  routes = []

  add_page: (page) ->
    # Complex, but the heart of the thing
    for route, method of page.routes
      do (method) ->
        handler = (args...) ->
          continuation = ->
            method_call = (-> page[method]?.apply(page, args) if method)
            if Router._active_page != page
              Router._active_page = page
              page.load method_call
            else
              method_call()
          if Router._active_page? && Router._active_page != page && Router._active_page.unload?
            Router._active_page.unload continuation
          else
            continuation()

        routes.push [route, '', handler]

  fallback: ''

  start: ->
    R = new Backbone.Router()
    # Fallback: it goes to Router.fallback (which is, by default, '')
    routes.unshift ['*path', '', (-> Router.redirect(Router.fallback))]
    R.route.apply(R, route_data) for route_data in routes
    Backbone.history.start()

  redirect: (route) ->
    window.location.hash = "#" + route

  hard_redirect: (route) ->
    window.location.href = route

class Channel
  subscribe: (type, fn, ctx) ->
    @events[type] ||= []
    @events[type].push({context: ctx, callback: fn || this})
  unsubscribe: (chn, fn) ->
    # pending
  publish: (type, args...) ->
    console.log 'published: ' + type
    unless @events[type] then return false
    for subscriber in @events[type]
      subscriber.callback.apply(subscriber.context, args)
  constructor: ->
    @events = {}

class PageSandbox
  constructor: ->
    _.extend(@, new Channel())
  page_root: '.e-page-root'
  get_root: ->
    $(@page_root)

class Page
  constructor: (description) ->
    _.extend(@, description)
    Router.add_page(@)
    @sandbox = new PageSandbox()

_.extend exports, { Router: Router, Page: Page, Channel: Channel }
