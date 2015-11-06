_   = require 'lodash'
Nt  = require './noitech.coffee'
gen = Nt.generate
eff = Nt.effect
say = require './say.coffee'

say   'Making times'

module.exports = (timings) ->
  _.map timings, (voice) ->
    _.map voice, (timing, i) ->
      _.reduce ( voice.slice 0, i + 1 ), (sum, item) ->
        sum + item

