R = (require './rplus')
util = (require './util')
rooms = [
  {
    name: 'room'
    camera: true
    connections: {
      adv: ['hall', 'vent']
      ret: ['arcade', 'kitchen']
    }
    states: [
      (m)-> "The room is empty"
      (m)-> "#{m.name} is just sitting there inanimate."
      (m)-> "#{m.name} has moved toward camera"
      (m)-> "#{m.name}'s face covers the whole camera"
    ]
  }
  {
    name: 'hall'
    camera: true
    connections: {
      adv: ['office']
      ret: ['room']
    }
    states: [
      (m)-> "The hall is empty."
      (m)-> "#{m.name} is in the hall"
      (m)-> "#{m.name}'s face covers the whole camera."
    ]
  }
  {
    name: 'vent'
    camera: true
    connections: {
      adv: ['office']
      ret: ['room']
    }
    states: [
      (m)-> "The vent is empty."
      (m)-> "There are eyes glowing in the dark in the back of the vent."
      (m)-> "#{m.name}'s face covers the whole camera"
    ]
  }
  {
    name: 'arcade'
    camera: true
    connections: {
      adv: ['room']
      ret: ['vent']
    }
    states: [
      (m)-> "The arcade is empty"
      (m)-> "#{m.name} is looking at you menacingly"
      (m)-> "#{m.name} is standing up."
    ]
  }
  {
    name: 'kitchen'
    camera: true
    connections: {
      adv: ['room']
      ret: ['arcade']
    }
    states: [
      (m)-> "The kitchen is empty"
      (m)-> "#{m.name} is standing and looking at you."
      (m)-> "#{m.name} is holding a knife"
    ]
  }
  {
    name: 'office'
    camera: false
    connections: {
      adv: []
      ret: []
    }
    states: [
      (m)-> "Your security office"
      (m)-> "HOLY CRAP HE'S GONNA KILL YOU!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    ]
  }
]
findByName = (util.findByName R.__, rooms)
getIndexByName = (name)-> (R.findIndex (R.propEq 'name', name), rooms)
getRetPositions = R.pipe(
  (R.prop 'connections')
  (R.prop 'ret')
  (R.map ((c)-> {room: c, state: (findByName c).states.length - 1}))
)

getAdvPositions = R.pipe(
  (R.prop 'connections')
  (R.prop 'adv')
  (R.map ((c)-> {room: c, state: 1}))
)

getAvailableMoves = ((roomName, stateIndex, locks)->
  curRoom = (findByName roomName)
  R.pipe(
    (R.when (()-> 1 is stateIndex),
      (R.concat (getRetPositions curRoom)))
    (R.when (()-> curRoom.states.length - 1 is stateIndex),
      (R.concat (getAdvPositions curRoom)))
    (R.when (()-> curRoom.states.length - 1 > stateIndex),
      (R.append {room: roomName, state: stateIndex + 1}))
    (R.when (()-> 1 < stateIndex),
      (R.append {room: roomName, state: stateIndex - 1}))
    (R.filter ((it)->
      R.pipe(
        (R.propOr 0, roomName)
        (R.propOr 0, it.room)
        R.not
      )(locks)
    ))
  )([]))

getRandomMove = ((monster, locks)->
  moves = (getAvailableMoves monster.room, monster.state, locks)
  rint = (util.getRandomInt rng, 0, moves.length)
  moves[rint]
)

getAttacked = (roomName)-> roomName is 'office'
rng = Math.random
module.exports = {
  setRNG: (generator)-> rng = generator
  byName: findByName
  getIndexByName: getIndexByName
  getRetPositions: getRetPositions
  getAdvPositions: getAdvPositions
  getRandomMove: getRandomMove
  getAttacked: getAttacked
  rooms: rooms
}
