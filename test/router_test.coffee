core = require('../assets/javascripts/core/router.js.coffee')
sinon = require('sinon')

describe 'Core', ->
  describe 'Router', ->
    describe 'add_page', ->
      it 'should initalize the routing system', ->
        fake_router = {
          route: sinon.spy(),
          start: sinon.spy()
        }
        core.Router.start(fake_router)
        fake_router.route.called.should.equal true
        fake_router.start.called.should.equal true

    it 'should store a router and a handler'

    it 'should store multiple routers with its handlers'

    it 'should call the "load" method of the page'

    it 'should change the active page'

    it 'should call the handler but not "load" when the page is active'
