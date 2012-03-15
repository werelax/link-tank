#= require core/router

exports ||= (this.W ||= {})

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
