module.exports =

  sine: (voice) ->
    voice = voice or {}
    amplitude = voice.amplitude or 1
    tone = voice.tone / 44100
    phase = voice.phase or 0
    output = []

    sampleIndex = 0
    while sampleIndex < voice.sustain
      sample = amplitude
      sample *= Math.sin((Math.PI * 2 * sampleIndex * tone) + phase)
      output.push sample
      sampleIndex++
    
    output



  saw: (voice) ->
    voice = voice or {}
    amplitude = voice.amplitude or 1

    output = []
    sampleIndex = 0
    while sampleIndex < voice.sustain
      output.push 0
      sampleIndex++

    harmonic = 1
    while harmonic <= voice.harmonicCount
      sampleIndex = 0
      while sampleIndex < voice.sustain

        enharmonic = 1
        if voice.enharmonicity isnt undefined
          enharmonic = (1 + voice.enharmonicity) ** (harmonic - 1) 

        decay = 1 
        if voice.harmonicDecay isnt undefined
          if harmonic > 1
            decay = sampleIndex ** 2
            decay++
            decay = decay ** 0.5
            decay = sampleIndex / decay
            decay = decay ** (voice.harmonicDecay / harmonic)
            decay = 1 - decay
          else
            decay = sampleIndex ** 2
            decay++
            decay = decay ** 0.5
            decay = sampleIndex / decay

        sample = amplitude * decay
        sample *= (-1 ** harmonic) / harmonic

        sineArgument = sampleIndex * Math.PI * 2
        sineArgument *= harmonic * enharmonic
        sineArgument *= (voice.tone / 44100)

        sample *= Math.sin(sineArgument)


        output[sampleIndex] += sample
        sampleIndex++
      harmonic++

    volumeNumerator = 2 * (voice.harmonicCount)
    
    volumeDenominator = voice.harmonicCount - 1
    volumeDenominator = volumeDenominator ** 2
    volumeDenominator++
    volumeDenominator = volumeDenominator ** 0.5
    volumeDenominator *= Math.PI

    harmonicVolumeAdjust = volumeNumerator / volumeDenominator

    sampleIndex = 0
    while sampleIndex < output.length
      output[sampleIndex] *= (1 - harmonicVolumeAdjust)
      sampleIndex++

    output



  triangle: (voice) ->
    voice = voice or {}
    amplitude = voice.amplitude or 1

    output = []
    sampleIndex = 0
    while sampleIndex < voice.sustain
      output.push 0
      sampleIndex++

    console.log voice

    harmonic = 0
    while harmonic < voice.harmonicCount
      sampleIndex++

      while sampleIndex < output.length

        enharmonic = 1
        if voice.enharmonicity isnt undefined
          enharmonic = (1 + voice.enharmonicity) ** (harmonic - 1) 

        decay = 1 
        if voice.harmonicDecay isnt undefined
          if harmonic > 1
            decay = sampleIndex ** 2
            decay++
            decay = decay ** 0.5
            decay = sampleIndex / decay
            decay = decay ** (voice.harmonicDecay / harmonic)
            decay = 1 - decay
          else
            decay = sampleIndex ** 2
            decay++
            decay = decay ** 0.5
            decay = sampleIndex / decay

        sample = amplitude * decay
        sample *= (-1 ** harmonic)
        sample /= ((harmonic * 2) + 1) ** 2

        sineArgument = Math.PI * sampleIndex * 2
        sineArgument *= voice.tone * ((harmonic * 2) + 1) * enharmonic

        sample *= Math.sin(sineArgument)

        output[sampleIndex] += sample

        sampleIndex++
      harmonic++

    amplitudeNumerator = 8 * (voice.harmonicCount - 1)
    
    amplitudeDenominator = (voice.harmonicCount - 1) ** 2
    amplitudeDenominator++
    amplitudeDenominator = amplitudeDenominator ** 0.5
    amplitudeDenominator *= (Math.PI ** 2)

    harmonicAmplitudeAdjust = amplitudeNumerator / amplitudeDenominator

    sampleIndex = 0
    while sampleIndex < output.length
      output[sampleIndex] *= (1 - harmonicAmplitudeAdjust)
      sampleIndex++

    output



  square: (voice) ->
    voice = voice or {}
    amplitude = voice.amplitude or 1

    output = []
    sampleIndex = 0
    while sampleIndex < voice.sustain
      output.push 0
      sampleIndex++   
      
    harmonic = 1
    while harmonic <= voice.harmonicCount
      sampleIndex = 0
      while sampleIndex < voice.sustain

        enharmonic = 1
        if voice.enharmonicity isnt undefined
          enharmonic = (1 + voice.enharmonicity) ** (harmonic - 1) 

        decay = 1 
        if voice.harmonicDecay isnt undefined
          if harmonic > 1
            decay = sampleIndex ** 2
            decay++
            decay = decay ** 0.5
            decay = sampleIndex / decay
            decay = decay ** (voice.harmonicDecay / harmonic)
            decay = 1 - decay
          else
            decay = sampleIndex ** 2
            decay++
            decay = decay ** 0.5
            decay = sampleIndex / decay

        sample = amplitude * decay
        sample /= ((harmonic * 2) - 1)

        sineArgument = sampleIndex * Math.PI * 2
        sineArgument *= ((harmonic * 2) - 1) * enharmonic
        sineArgument *= (voice.tone / 44100)

        sample *= Math.sin(sineArgument)

        output[sampleIndex] += sample
        sampleIndex++
      harmonic++ 

    amplitudeNumerator = 4 * (voice.harmonicCount - 1)
    
    amplitudeDenominator = voice.harmonicCount - 1
    amplitudeDenominator = amplitudeDenominator ** 2
    amplitudeDenominator++
    amplitudeDenominator = amplitudeDenominator ** 0.5
    amplitudeDenominator *= Math.PI

    harmonicAmplitudeAdjust = amplitudeNumerator / amplitudeDenominator
    sampleIndex = 0

    while sampleIndex < output.length
      output[sampleIndex] *= (1 - harmonicAmplitudeAdjust)
      sampleIndex++

    output



  silence: (voice) ->
    voice = voice or {}
    output = []
    sampleIndex = 0

    while sampleIndex < voice.sustain
      output.push 0
      sampleIndex++

    output






