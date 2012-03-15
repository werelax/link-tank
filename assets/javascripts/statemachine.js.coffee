# Objetives:
# - Flexible, powerful SM library
# (1) Define behaviour by state (like fm-firefox-addon)
# (2) Define behaviour by transition (like pusher)
# (3) Define behaviour by filters (like rails controllers)
# (4) Trigger by events

# Improvements:
# (1) The W.Channel() should be external.
#   1.a - Provide a way to feed events to the machine flexibly
#         (being W.Channel adapted to this)

# Things I like:
#   - Extremely flexible: you can use it in many different ways
#   - CONTINUATIONS in transitions (I really like this!)
#   - Filters (at least the _.reduce is cool!)
#   - The @send input events

# Points to think:
#   - Remove the user-triggered transitions. Transitions should
#     only happen after an INPUT (event)
#
#   - Clear a little bit what happens to the arguments of the event
#
#   - A FLEXIBLE way to notify state changes
#     something where I can plug an event emitter later

exports = (this['W'] ||= {})

class StateMachine
  constructor: (events: @events, context: @context) ->
    @events  ||= {}
    @context ||= {}
    @states      = {}
    @transitions = {}
    @filters     = {}
    @send        = {}

  start: (initial_state) ->
    @parse_events()
    @enter_state(initial_state)

  parse_events: ->
    sm = @
    all_states = _.keys(@states)
    _.each @events, (event) ->
      event.from = all_states if event.from == '*'
      origins = if _.isArray(event.from) then event.from else [event.from]
      sm.send[event.name] = (args...) ->
        sm.state_change(event.to, args) if sm.active_state in origins

  validate_transition: (new_state) ->
    current = @states[@active_state]
    restricted = current.allow? && _.indexOf(current.allow, new_state) == -1
    restricted ||= current.restrict? && _.indexOf(current.restrict, new_state) > -1
    return !restricted

  state_change: (new_state, args) ->
    return unless @validate_transition(new_state)
    sm = @
    context = sm.context
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
      sm.leave_current_state()
      sm.enter_state(new_state, context, args)

  leave_current_state: ->
    @states[@active_state].leave()
    @active_state = null

  enter_state: (new_state, context, args) ->
    @states[@active_state].leave() if @active_state
    @states[new_state].enter.apply(context, args)
    @active_state = new_state

  # Filters
  before_filters_for: (state) ->
    filters = []
    append = (source) ->
      return unless source?
      if _.isFunction(source)
        filters.push(source)
      else if _.isArray(source)
        filters = filters.concat(source.reverse())
    append(@filters["before_#{state}"])
    append(@filters.before_all)
    return filters

exports['StateMachine'] = StateMachine

### Examples of usage

window.sm = new Wrlx.StateMachine
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

###
