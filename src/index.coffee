views = require './views'
actions = require './actions'
util = require './util'
R = (require './rplus')
flyd = require 'flyd'
flydEvery = (require 'flyd-every')


seed = 'ohai'
random = (require 'seedrandom')

MAX_TIME = 60 * 6
MOVE_INTERVAL = 6
DEFAULT_STATE = {
  time: MAX_TIME
  startTime: Date.now()
  night: 1
  power: 200
  currentRoom: 'office'
  locks: {
    vent: {office: 0}
    hall: {office: 0}
  }
  monsters: [
    {
      name: 'Caddy'
      room: 'room'
      state: 1
    }
    {
      name: 'Lizo'
      room: 'arcade'
      state: 1
    }
  ]
}



monstersLens = (R.lensProp 'monsters')

look = R.tap(console.log.bind(console))

lookBy = (R.curry (fn, x)->
  (console.log (fn x))
  x
)

rooms = (require './rooms')

monsterBrain = ((state)->
  (monstersLens.map (R.map ((m)->
    if m.room isnt state.currentCamera and state.time and state.time % MOVE_INTERVAL is 0
      lookBy ((m)->"#{m.name}: #{m.room} - #{m.state}"), (R.merge m, (rooms.getRandomMove m, state.locks))
    else m
  )), state)
)

parseParams = (str)->
  firstQ = str.indexOf '?'
  R.ifElse(
    (()-> firstQ > 0)
    R.pipe(
      (R.drop firstQ + 1)
      (R.split "&")
      (R.map (do R.split '='))
      R.fromPairs
      (R.assoc 'action', (R.take firstQ, str))
    )
    (R.createMapEntry 'action')
  )(str)

powerLens = (R.lensProp 'power')
decPower = (powerLens.map (R.add -1))

powerOut = (state)->
  if state.power <= 0
    state.currentRoom = 'powerOut'
  state

timeOut = (state)->
  if state.time <= 0
    state.currentRoom = 'win'
  state

attack = R.when(
  R.pipe(
    (R.prop 'monsters')
    R.any R.propEq('room', 'office')
  )
  (state)->
    (R.assoc 'currentRoom', 'attack', state)
)
# state -> state
tick = R.pipe(
  (state)->
    elapsed = (Math.floor (state.now - state.startTime) / 1000)
    (R.assoc 'time', (MAX_TIME - elapsed), state)
  (R.when (R.path ['locks', 'hall', 'office']), decPower)
  (R.when (R.path ['locks', 'vent', 'office']), decPower)
  # (R.when (R.propEq 'currentRoom', 'computer'), decPower)
  powerOut
  monsterBrain
  attack
  timeOut
)

start = ((io)->
  rngState = (random Date.now(), {state: true})
  #(rooms.setRNG rngState)
  state$ = (flyd.stream (R.assoc 'rng', rngState, DEFAULT_STATE))
  sec$ = (flydEvery 1000)

  io.presse$.map (params)->
    (state$ (handleAction params, (do state$)))

  # push to stream each second
  (sec$.map (now)->
    nextState = (R.assoc 'now', now, (do state$))
    (state$ tick nextState))
  (state$.map draw canvas)
)

(document.addEventListener 'DOMContentLoaded', (e)->
  canvas = (document.getElementById 'canvas')
  presse$ = (do flyd.stream)
  (canvas.addEventListener 'mousedown', (e)->
    target = e.target
    if target.tagName is 'A'
      params = (parseParams (R.drop 1, target.hash))
      if (R.keys params).length
        (presse$ params)
        (do e.preventDefault)
  )
  start({presse$: presse$})
)

draw = (R.curry ((canvas, state)->
  html = (R.pipe (views[state.currentRoom]),
    (R.replace /\s\s\n/g, '<br>'),
    (R.replace /\n\n/g, '<br><br>'))(state)
  canvas.innerHTML = html))

handleAction = (R.curry (params, state)->
  actionName = params.action
  action = actions[actionName] or (actions['error'] actionName + " is not a action")
  (action state, params))