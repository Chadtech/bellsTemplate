_        = require 'lodash'
Nt       = require './noitech.coffee'
gen      = Nt.generate
eff      = Nt.effect
cp       = require 'child_process'
fs       = require 'fs'
say      = require './say.coffee'
play     = require './play.coffee'
Channel  = require './channel.coffee'
stdin    = process.openStdin()


{getFileName, removeFileExtension, getFileExtension} = 
  require './file-name-utilities.coffee'

justPlayed = ''
voiceCount = 6

lines       = undefined
timings     = (require './init-timings.coffee') null, voiceCount
timingsSeed =  timings.seed
timings     =  timings.timings
times       = (require './init-times.coffee') timings
voices      =  require './init-voices.coffee'

partLengths = [
  136
  128
  128
  128
  128
  128
  128
]

buildProcess = (sliceAt, duration) => 

  sliceAt  = parseInt sliceAt
  duration = parseInt duration

  say 'Compiling'

  score = (require './get-score.coffee') voiceCount, 
    partLengths

  if not (isNaN (duration + sliceAt))
    lines = (require './init-lines.coffee') voiceCount, 
      times[0][ duration + sliceAt ] + (44100 * 6)
  else
    lines = (require './init-lines.coffee') voiceCount, 
      times[0][times[0].length - 1] + (44100 * 6)

  lines = (require './part.coffee') score, 
    sliceAt
    duration
    voices
    lines
    times
    timings
    voiceCount

  Channels = (require './init-channels.coffee') lines[0].length 
  Channels = Channel Channels, lines

  say 'Building from ' + sliceAt 
  Nt.buildFile 'bells12.wav', _.map Channels, (channel) ->
    Nt.convertTo64Bit channel

  say 'Done compiling'


say 'Ready'

console.log 'Bells 12 App Terminal :'
stdin.addListener 'data', (d) ->

  d = d.toString().trim()
  d = d.split ' '

  switch d[0]

    when 'build'

      if d[1] isnt undefined
        buildProcess d[1], d[2]
      else
        buildProcess false
            
    when 'play'
      say 'Playing'

      if d[1]

        f = './' + d[1] + '.wav'
        if fs.existsSync f
          play './' + d[1] + '.wav'
        else
          say 'File does not exist'

        justPlayed = d[1]

      else
        play './bells12.wav'
        say 'Finished playing'

    when 'new'
      if d[1] is 'timings'

        say 'New Timings'

        timings     = (require './init-timings.coffee') null, voiceCount
        timingsSeed =  timings.seed
        timings     =  timings.timings
        times       = (require './init-times.coffee') timings

        say 'Finished Timings'

      else
        say 'Nope'

    else
      say 'Does not compute'






