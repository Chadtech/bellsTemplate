_     = require 'lodash'
Nt    = require './noitech.coffee'
gen   = Nt.generate
eff   = Nt.effect
cp    = require 'child_process'

tonic = 20
tones = [
  1       # 1/1
  1.143   # 8/7
  1.313   # 21/16
  1.524   # 32/21
  1.75    # 7/4
]

inharmonicity = 1.01
bellDuration = 44100 * 4

octaves = [ 0 .. 8 ]
octaves = _.map octaves, (octave) ->
  _.map tones, (tone, toneIndex) ->
    output = tonic * (2 ** octave) * tone
    output *= inharmonicity ** ((toneIndex + (octave * tones.length)) // tones.length)
    output

noteTotal = octaves.length * octaves[0].length

octaves = _.map octaves, (octave, octaveIndex) ->
  _.map octave, (tone, toneIndex) ->

    noteTotal

    sounds = []

    a = 0.5

    fundamental = gen.sine
      amplitude: a
      tone:      tone
      sustain:   bellDuration * 0.6
    sounds.push fundamental

    a /= 2

    firstHarmonic = gen.sine
      amplitude: a
      tone:      tone * 2
      sustain:   bellDuration * 0.25
    sounds.push firstHarmonic

    subHarmonic = gen.sine
      amplitude: a
      tone:      tone / 2
      sustain:   bellDuration
    sounds.push subHarmonic


    a /= 2
    a *= (0.8 - (((toneIndex + (octaveIndex * octaves[0].length)) / noteTotal) * 0.8)) + 0.2

    secondHarmonic = gen.sine
      amplitude: a
      tone:      tone * 3
      sustain:   bellDuration * 0.2
    sounds.push secondHarmonic


    a /= 2
    a *= (0.8 - (((toneIndex + (octaveIndex * octaves[0].length)) / noteTotal) * 0.8)) + 0.2

    thirdHarmonic = gen.sine
      amplitude: a
      tone:      tone * 4.26
      sustain:   bellDuration * 0.3
    sounds.push (eff.fadeOut thirdHarmonic)


    a /= 2
    a *= (0.8 - (((toneIndex + (octaveIndex * octaves[0].length)) / noteTotal) * 0.8)) + 0.2
    

    fourthHarmonic = gen.sine
      amplitude: a
      tone:      tone * 5.55
      sustain:   bellDuration * 0.26
    sounds.push (eff.fadeOut fourthHarmonic)


    a /= 2
    a *= (0.8 - (((toneIndex + (octaveIndex * octaves[0].length)) / noteTotal) * 0.8)) + 0.2


    fifthHarmonic = gen.sine
      amplitude: a
      tone:      tone * 7.02
      sustain:   bellDuration * 0.15
    sounds.push (eff.fadeOut fifthHarmonic)


    a /= 2.5
    a *= (0.8 - (((toneIndex + (octaveIndex * octaves[0].length)) / noteTotal) * 0.8)) + 0.2


    sixthHarmonic = gen.sine
      amplitude: a
      tone:      tone * 8.1
      sustain:   bellDuration * 0.14
    sounds.push (eff.fadeOut sixthHarmonic)


    sounds = _.map sounds, (sound, soundIndex) ->
      if soundIndex < (sound.length / 2)
        eff.vol (eff.fadeOut (eff.fadeOut sound)), factor: 0.6
      else
        eff.vol (eff.fadeOut (eff.fadeOut (eff.fadeOut sound))), factor: 0.6

    enharmonics = [
      {relativePitch: 0.6, volume: 0.09, duration: 0.05}
      {relativePitch: 1.5, volume: 0.05, duration: 0.055}
      {relativePitch: 1.6, volume: 0.04, duration: 0.06}
      {relativePitch: 2.2, volume: 0.04, duration: 0.065}
      {relativePitch: 3.8, volume: 0.04, duration: 0.003}
      {relativePitch: 4.0, volume: 0.05, duration: 0.002}
      {relativePitch: 4.9, volume: 0.04, duration: 0.003}
      {relativePitch: 5.1, volume: 0.03, duration: 0.004}
      {relativePitch: 5.6, volume: 0.05, duration: 0.002}
      {relativePitch: 5.7, volume: 0.04, duration: 0.003}
      {relativePitch: 5.8, volume: 0.03, duration: 0.004}
      {relativePitch: 6.6, volume: 0.03, duration: 0.004}
      {relativePitch: 7.4, volume: 0.03, duration: 0.001}
      {relativePitch: 7.7, volume: 0.02, duration: 0.001}
      {relativePitch: 16.7, volume: 0.1, duration: 0.003}
      {relativePitch: 10.7, volume: 0.02, duration: 0.001}
    ]

    enharmonics = _.map enharmonics, (enharmonic) ->
      thisEnharmonic = gen.sine 
        amplitude: enharmonic.volume
        tone:      tone * enharmonic.relativePitch
        sustain:   enharmonic.duration

      eff.fadeOut thisEnharmonic


    sounds = sounds.concat enharmonics
    sounds.unshift (gen.silence sustain: bellDuration)

    output = _.reduce sounds, (mix, sound) ->
      Nt.mix sound, mix, 0

    output = eff.ramp output

    fileName = 'bellI/bellI'
    fileName += octaveIndex 
    fileName += toneIndex 
    fileName += '.wav'
    
    Nt.buildFile fileName, [ Nt.convertTo64Bit output ]
    cmd = './convolveMono '
    cmd += fileName + ' expensiveE.wav convolveItem.wav'
    cmd += ' 0.15'
    cp.execSync cmd

    convolvedOut = Nt.open 'convolveItem.wav'
    convolvedOut = Nt.convertToFloat convolvedOut[0]

    output = Nt.mix (Nt.convertToFloat output), convolvedOut, 0
    Nt.buildFile fileName, [ Nt.convertTo64Bit output ]

    console.log tone

    0

