# Objetives:
# - Flexible, powerful SM library
# (1) Define behaviour by state (like fm-firefox-addon)
# (2) Define behaviour by transition (like pusher)
# (3) Define behaviour by filters (like rails controllers)
# (4) Trigger by events

exports = (this['Wrlx'] ||= {})

class StateMachine
  constructor: (name: @name, channel: @channel, events: @events) ->
    @channel ||= new Wrlx.Channel()
    @_event_prefix = if @name? then "#{@name}:" else ""
    @active_state = undefined
    @states = {}
    @transitions = {}
    @filters = {}
    @send = {}

  start: (initial_state) ->
    sm = @
    for event in @events
      do (event) ->
        origins = if event.from == '*'
          state for state,__ of sm.states
        else if typeof(event.from) == 'string'
          [event.from]
        else
          event.from
        handler = (args...) ->
          if _.indexOf(origins, sm.active_state) != -1
            sm.state_change.apply(sm, [event.to].concat(args))
        sm.channel.subscribe event.name, handler
        sm.send[event.name] = handler
    @enter_state(initial_state)

  validate_transition: (new_state) ->
    current = @states[@active_state]
    restricted = current.allow? && _.indexOf(current.allow, new_state) == -1
    restricted ||= current.restrict? && _.indexOf(current.restrict, new_state) > -1
    return !restricted

  state_change: (new_state, args...) ->
    return unless @validate_transition(new_state)
    sm = @
    context = {}
    leave_previus_continuation = ->
      sm.leave_current_state()
      # after_filters here
    enter_next_continuation = (args) ->
      filters = sm.before_filters_for(new_state)
      filter_chain = _.reduce(
        filters,
        (acc, f) -> _.bind((-> f(sm, acc)), context),
        -> sm.enter_state(new_state, context, args))
      filter_chain()
    transition_name = "#{sm.active_state}_#{new_state}"
    if @transitions[transition_name]
      @transitions[transition_name].call(context, leave_previus_continuation, enter_next_continuation, args)
    else
      leave_current_state()
      enter_state.apply(this, args)
  leave_current_state: ->
    @states[@active_state].leave()
    @active_state = null
  enter_state: (new_state, context, args) ->
    context ||= {}
    @states[@active_state].leave() if @active_state
    @states[new_state].enter.apply(context, args)
    @active_state = new_state

  # Filters
  before_filters_for: (state) ->
    filters = []
    append = (source) ->
      if source?
        if _.isFunction(source)
          filters.push(source)
        else if _.isArray(source)
          filters = filters.concat(source.reverse())
    append(@filters["before_#{state}"])
    append(@filters.before_all)
    return filters

  subscribe: (args...) ->
    @channel.subscribe.apply(@channel, args)
  publish: (args...) ->
    @channel.publish.apply(@channel, args)

exports['StateMachine'] = StateMachine

### Examples of usage

window.sm = new Wrlx.StateMachine
  name: 'test_machine'
  states: ['uno', 'dos', 'tres']
  events: [
    {name: 'move_to_dos', from: 'uno', to: 'dos'},
    {name: 'move_to_tres', from: '*', to: 'tres'} ]

sm.states =
  uno:
    enter: (req) ->
      console.log "[flash] #{this.flash}" if this.flash?
      console.log("Enter state: UNO!")
    leave: -> console.log("Leave state: UNO...")
  dos:
    enter: -> console.log("Enter state: DOS!")
    leave: -> console.log("Leave state: DOS...")
  tres:
    enter: -> console.log("Enter state: TRES!")
    leave: -> console.log("Leave state: TRES...")

sm.transitions =
  uno_dos: (leave, enter, args) ->
    leave()
    setTimeout(enter, 200)

sm.filters =
  before_all: (sm, next) ->
    next()
  before_dos: [
    ((sm, next) ->
      sm.enter_state('tres')
      setTimeout(next, 2000)),
    ((sm, next) ->
      console.log("second filter")
      next()) ]

sm.start('uno')
