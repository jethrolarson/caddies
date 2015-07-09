#:: [{k: v}] -> {k: {k: v}}
recordsByKey = (key)-> R.reduce ((acc, it)->
  R.assoc R.prop(key, it), it, acc
), {}