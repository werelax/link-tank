Session = {}

Login = new W.Page
  routes:
    '':      false
    'login': false
  load: (cb) ->
    if Session['logged']?
      W.Router.redirect('main')
      return
    @sandbox.publish('enter')
    root = @sandbox.get_root()
    root.hide()
    root.html T['templates/pages/login/root']
    root.fadeIn cb
  unload: (cb) ->
    root = @sandbox.get_root()
    root.fadeOut =>
      @sandbox.publish('leave')
      $(document.body).hide()
      cb()
      $(document.body).fadeIn()

Main = new W.Page
  routes:
    'main': false
    'search/*query': 'do_search'
  load: (cb) ->
    Session['logged'] = true
    root = @sandbox.get_root()
    root.html T['templates/pages/main/root']
    cb()
  do_search: (query) ->
    console.log 'Searching for:' + query


$ ->
  set_fixed_template = -> document.body.innerHTML = T['templates/layouts/fixed']
  set_fluid_template = -> document.body.innerHTML = T['templates/layouts/fluid']

  set_fluid_template()

  Login.sandbox.subscribe 'enter', set_fixed_template
  Login.sandbox.subscribe 'leave', set_fluid_template

  W.Router.start()
