# Node boilerplate for testing

if require?
  _ = require 'underscore'
  $ = require 'jquery'

##

exports ||= (this.W ||= {})

# Impossible to test! Way, way to coupled to Backbone!
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
