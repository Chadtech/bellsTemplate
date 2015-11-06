_   = require 'lodash'
Nt  = require './noitech.coffee'
gen = Nt.generate
eff = Nt.effect
say = require './say.coffee'

module.exports = (seed, vc) ->

  say 'Making timings'

  timings = undefined
  if seed is null
    beatDuration    = 5513
    timings         = [ 0 ]
    _.times (64 * 30),  =>
      randomness    = Math.random() / 80
      time          = randomness
      time         +=  1 - (1 / 160)
      time         *= beatDuration
      beatDuration  =  time // 1
      timings.push time 
  else
    timings = seed

  alltimings = []

  _.times vc, ->
    anotherTime = _.map timings, (time) ->
      (time + (Math.random() * 200) - 100) // 1
    alltimings.push anotherTime

  output =
    seed:    _.map timings, (t) -> t // 1
    timings: alltimings

  output