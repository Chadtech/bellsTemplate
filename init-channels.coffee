_   = require 'lodash'
Nt  = require './noitech.coffee'
gen = Nt.generate
eff = Nt.effect
say = require './say.coffee'

say 'Forming Channels'

returnLines = (duration) ->

  channels = []
  _.times 2, ->
    channels.push gen.silence sustain: duration

  channels

module.exports = returnLines