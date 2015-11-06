_   = require 'lodash'
Nt  = require './noitech.coffee'
gen = Nt.generate
eff = Nt.effect
say = require './say.coffee'

returnLines = (vc, duration) ->

  say 'Forming Lines'

  if duration is undefined
    duration = 140000

  # duration *= 2

  lines = []
  _.times vc, ->
    lines.push gen.silence sustain: duration

  lines

module.exports = returnLines