R = (require 'ramda')
R.when = ((pred, fn)-> (R.ifElse pred, fn, R.identity))

module.exports = R