R = (require './rplus')
util = (require './util')

changeRoom    = (R.assoc 'currentRoom')
changeCamera  = (R.assoc 'currentCamera')
lockedLens    = (R.lensProp 'locked')
locksLens     = (R.lensProp 'locks')

module.exports = {
  error: R.useWith(
    R.assoc('error')
    R.identity, #msg
    (changeRoom 'error') #state
  )
  computer: (changeRoom 'computer')
  office: (changeRoom 'office')
  camera: (state, params)->
    (changeCamera params.name, state)
  door: (state)->
    state.locks.hall.office = !state.locks.hall.office
    state
  fan:  (state)->
    state.locks.vent.office = !state.locks.vent.office
    state
  restart: (state)->
    state
}