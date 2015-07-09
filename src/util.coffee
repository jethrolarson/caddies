# Returns a random integer between min (included) and max (excluded)
# Using Math.round() will give you a non-uniform distribution!
R = (require './rplus')
getRandomInt = R.curry (rng, min, max)->
  (Math.floor (rng() * (max - min)) + min)

raf = (window.webkitRequestAnimationFrame.bind window)

module.exports = {
  getRandomInt: getRandomInt
  raf: raf
  pad: ((size, num) ->
    s = num + ""
    while s.length < size
      s = "0" + s;
    s
  )
  findByName: (R.useWith R.find, (R.propEq 'name'), R.identity)
}