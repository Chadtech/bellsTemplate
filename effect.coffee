# speed of sound in meters per sample is 0.0078 meters per sample

module.exports =


  # invert the amplitude at each sample, meaning that
  # for each sample, where sample is a number, 
  # multiply that number by negative one
  invert: (input) ->
    output = []

    sampleIndex = 0
    while sampleIndex < input.length
      output.push input[sampleIndex] * -1
      sampleIndex++

    output


  shift: (input, effect) ->
    output = []
    if (effect.shift is 0) or (effect.shift is undefined)
      return input

    if effect.shift > 0
      input = [0].concat input
    else
      input = input.concat [0]

    shiftMagnitude = Math.abs(effect.shift)
    sampleIndex = 0
    while sampleIndex < input.length
      sample = input[sampleIndex] * (1 - shiftMagnitude) 
      sample += input[sampleIndex + 1] * shiftMagnitude
      output.push sample
      sampleIndex++

    output


  giveSpatiality: (input, effect) ->
    output = []
    speedOfSound = 0.0078
    xpos = effect.xpos or 1
    ypos = effect.ypos or 1
    leftEar = xpos - 0.05
    rightEar = xpos + 0.05

    leftEarDist = leftEar ** 2
    leftEarDist += ypos ** 2
    leftEarDist = leftEarDist ** 0.5

    rightEarDist = rightEar ** 2
    rightEarDist += ypos ** 2
    rightEarDist = rightEarDist ** 0.5

    leftEarDelay = leftEarDist * speedOfSound
    rightEarDelay = rightEarDist * speedOfSound

    leftEarContent = @padBefore input, 
      paddingAmount: leftEarDelay // 1
    leftEarContent = @shift input,
      shift: leftEarDelay % 1

    rightEarContent = @padBefore input,
      paddingamount: rightEarDelay // 1
    rightEarContent = @shift input,
      shift: rightEarDelay % 1

    [leftEarContent, rightEarContent]


  padBefore: (input, effect) ->
    paddingAmount = effect.paddingAmount or 30
    output = []
    
    padding = 0
    while padding < paddingAmount
      output.push 0
      padding++

    output = output.concat input
    output



  paddAfter: (input, effect) ->
    paddingAmount = effect.paddingAmount or 30
    output = []

    padding = 0
    while padding < paddingAmount
      output.push 0
      padding++

    output = input.concat output
    output



  delay: (input, effect) ->
    output = []
    sampleIndex = 0
    finalLength = input.length
    finalLength += (effect.numberOf * effect.distance)
    while sampleIndex < finalLength
      output.push 0
      sampleIndex++

    sampleIndex = 0
    while sampleIndex < input.length
      delayIndex = 0
      while delayIndex < effect.numberOf
        inputIndex = sampleIndex + (delayIndex * effect.distance)
        decay = effect.decayRate * delayIndex
        output[sampleIndex] += input[inputIndex] * decay
        delayIndex++
      sampleIndex++

    output


  # 1024 is a pretty good effect.factor
  bitCrush: (input, effect) ->
    output = []

    sampleIndex = 0
    while sampleIndex < input.length
      crushed = ( input[sampleIndex] // effect.factor ) * effect.factor
      output.push crushed
      sampleIndex++

    output


  clip: (input, effect) ->
    threshold = effect.threshold or 1
    threshold = threshold // 1
    output = []

    sampleIndex = 0
    while sampleIndex < input.length
      if input[sampleIndex] > threshold or (-1 * threshold) > input[sampleIndex] 
        signPreserve = input[sampleIndex] / Math.abs(input[sampleIndex])
        output.push threshold * signPreserve
      else 
        output.push input[sampleIndex]
      sampleIndex++

    output



  vol: (input, effect) ->
    output = []
    
    for sample in input
      output.push sample * effect.factor
    
    output



  fadeOut: (input, effect) ->
    effect = effect or {}
    whereBegin = effect.beginAt or 0
    whereEnd = effect.endAt or (input.length)
    finalVolume = effect.volumeAtEnd or 0
    rateOfReduction = (1 - finalVolume) / (whereEnd - whereBegin)

    output = []

    sampleIndex = 0
    while sampleIndex < whereBegin
      output.push input[sampleIndex]
      sampleIndex++

    reductionIndex = 0
    while sampleIndex < whereEnd
      reduction = (1 - (reductionIndex * rateOfReduction))
      fadedSample = input[sampleIndex] * reduction
      output.push fadedSample
      reductionIndex++
      sampleIndex++

    while sampleIndex < input.length
      output.push input[sampleIndex] * finalVolume
      sampleIndex++

    output



  fadeIn: (input, effect) ->
    effect = effect or {}
    whereBegin = effect.beginAt or 0
    whereEnd = effect.endAt or input.length - 1
    startVolume = effect.volumeAtStart or 0
    rateOfIncrease = (1 - startVolume) / (whereEnd - whereBegin)

    output = []

    sampleIndex = 0
    while sampleIndex < whereBegin
      output.push input[sampleIndex] * startVolume
      sampleIndex++

    reductionIndex = 0
    durationOfFade = whereEnd - whereBegin
    while sampleIndex < durationOfFade
      increase = ((durationOfFade - reductionIndex) * rateOfIncrease)
      output.push input[sampleIndex] * (1 - increase)
      reductionIndex++
      sampleIndex++

    while sampleIndex < input.length
      output.push input[sampleIndex]
      sampleIndex++

    output



  rampOut: (input, effect) ->
    effect = effect or {}
    ramp = effect.rampLength or 60

    rampParameters =
      beginAt: input.length - ramp

    @fadeOut(input, rampParameters)

  
  rampIn: (input, effect) ->
    effect = effect or {}
    ramp = effect.rampLength or 60

    rampParameters =
      endAt: ramp

    @fadeIn(input, rampParameters)


  ramp: (input, effect) -> 
     @rampIn @rampOut(input, effect), effect


  reverse: (input) ->
    input.reverse()


  cutUpEveryGrain: (input, threshold) ->
    grains = []
    beginning = 0
    ending = 0
    sampleIndex = 0

    while sampleIndex < input.length
      if input[sampleIndex] < threshold
        ending = sampleIndex
        grains.push input.slice(beginning, ending)
        beginning = sampleIndex
      sampleIndex++

    grains


  reverb: (input, effect) ->
    decay0 = 0.5 or effect.decay0
    decay1 = 0.5 or effect.decay1

    delays0 = [
      1115
      1188
      1356
      1277
      1422
      1491
      1617
      1557
    ] or effect.delays0

    delays1 = [
      255
      556
      441
      341
    ] or effect.delays1

    reverbBackPass = (subRay, decay, delays) ->
      arrayOfDelayeds = []
      delay = 0

      while delay < delays.length
        arrayOfDelayeds.push []
        padding = 0

        while padding < delays[delay]
          arrayOfDelayeds[arrayOfDelayeds.length - 1].push 0
          padding++
        sample = 0

        while sample < subRay.length
          arrayOfDelayeds[arrayOfDelayeds.length - 1].push subRay[sample]
          sample++
        sample = 0

        while sample < subRay.length
          arrayOfDelayeds[arrayOfDelayeds.length - 1][sample] += arrayOfDelayeds[arrayOfDelayeds.length - 1][sample + delays[delay]] * decay
          sample++
        delay++
      backOutRay = []
      time = 0

      while time < (Math.max.apply(null, delays) + subRay.length)
        backOutRay.push 0
        time++
      delayedArray = 0

      while delayedArray < arrayOfDelayeds.length
        sample = 0

        while sample < arrayOfDelayeds[delayedArray].length
          backOutRay[sample] += arrayOfDelayeds[delayedArray][sample] / arrayOfDelayeds.length
          sample++
        delayedArray++
      backOutRay

    reverbForwardPass = (subRay, decay, undelays) ->
      arrayOfUndelayeds = []
      undelay = 0

      while undelay < undelays.length
        arrayOfUndelayeds.push []
        time = 0

        while time < (undelays[undelay] + subRay.length)
          arrayOfUndelayeds[arrayOfUndelayeds.length - 1].push 0
          time++
        sample = 0

        while sample < subRay.length
          arrayOfUndelayeds[arrayOfUndelayeds.length - 1][sample + undelays[undelay]] += subRay[sample] * decay
          sample++
        undelay++
      forwardOutRay = []
      time = 0

      while time < (Math.max.apply(null, undelays) + subRay.length)
        forwardOutRay.push 0
        time++
      undelayedArray = 0

      while undelayedArray < arrayOfUndelayeds.length
        sample = 0

        while sample < arrayOfUndelayeds[undelayedArray].length
          forwardOutRay[sample] += arrayOfUndelayeds[undelayedArray][sample] / undelays.length
          sample++
        undelayedArray++
      forwardOutRay

    backPass = reverbBackPass(input, decay0, delays0)
    reverbForwardPass backPass, decayON, delaysON


  convolve: (input, effect) ->
    effect = effect or {}
    factor = effect.factor or 0.05
    seed = effect.seed
    output = []

    time = 0
    while time < (input.length + seed.length)
      output.push 0
      time++

    sampleIndex = 0
    while sampleIndex < input.length
      convolveIndex = 0
      while convolveIndex < seed.length
        sample = input[sampleIndex] * seed[convolveIndex]
        #sample /= 32767
        sample *= factor 
        output[sampleIndex + convolveIndex] += sample
        convolveIndex++
      sampleIndex++

    output



  factorize: (fraction) ->
    numeratorsFactors = []
    denominatorsFactors = []

    isInteger = (number) ->
      if number % 1 is 0
        return true
      else
        return false

    denominatorCandidate = 1
    while not isInteger(fraction * denominatorCandidate)
      denominatorCandidate++

    denominator = denominatorCandidate
    numerator = fraction * denominator

    factoringCandidate = 2
    while factoringCandidate <= denominator
      if isInteger(denominator / factoringCandidate)
        denominator /= factoringCandidate
        denominatorsFactors.push factoringCandidate
      else
        factoringCandidate++

    factoringCandidate = 2
    while factoringCandidate <= numerator
      if isInteger(numerator / factoringCandidate)
        numerator /= factoringCandidate
        numeratorsFactors.push factoringCandidate
      else
        factoringCandidate++

    [numeratorsFactors, denominatorsFactors]



  speed: (input, effect) ->
    output = []
    factors = @factorize effect.factor

    multiplySpeed = (sound, factorIncrease) ->
      spedUpSound = []
      interval = 0

      while interval < (input.length // factorIncrease)
        averageValue = 0
        sampleIndex = 0
        while sampleIndex < factorIncrease
          intervalIndex = sampleIndex + (interval * factorIncrease)
          averageValue += sound[intervalIndex]
          sampleIndex++
        averageValue /= factorIncrease

        spedUpSound.push averageValue
        interval++

      if (sound.length / factorIncrease) % 1 isnt 0
        amountOfEndSamples = (sound.length // factorIncrease)
        amountOfEndSamples *= factorIncrease
        amountOfEndSamples = input.length - amountOfEndSamples
        unless amountOfEndSamples < (factorIncrease / 2)
          averageValue = 0
          sampleIndex = 0

          while sampleIndex < amountOfEndSamples
            averageValue += sound[sound.length - 1 - sampleIndex]
            sampleIndex++

          averageValue /= amountOfEndSamples
          spedUpSound.push averageValue

      spedUpSound
 

    divideSpeed = (sound, factorDecrease) ->
      slowedDownSound = []

      sampleIndex = 0
      while sampleIndex < (sound.length - 1)
        amplitudeDifference = sound[sampleIndex + 1]
        amplitudeDifference -= sound[sampleIndex]

        differenceAcrossDistance = amplitudeDifference
        differenceAcrossDistance /= factorDecrease

        intervalIndex = 0
        while intervalIndex < factorDecrease
          sample = sound[sampleIndex]
          sample += Math.round(intervalIndex * differenceAcrossDistance)
          slowedDownSound.push sample
          intervalIndex++
        sampleIndex++

      unAverageableEndBitIndex = 1
      while unAverageableEndBitIndex < factorDecrease
        slowedDownSound.push sound[sound.length - 1]
        unAverageableEndBitIndex++

      slowedDownSound


    decreaseIndex = 0
    while decreaseIndex < factors[1].length
      input = divideSpeed(input, factors[1][decreaseIndex])
      decreaseIndex++

    increaseIndex = 0
    while increaseIndex < factors[0].length
      input = multiplySpeed(input, factors[0][increaseIndex])
      increaseIndex++

    input



  grain: (input, effect) ->
    output = []
    factor = effect.factor or 1
    grainLength = effect.grainLength
    passes = effect.passes
    grainRate = grainLength / passes
    grains = []

    sampleIndex = 0
    while sampleIndex < input.length
      startingSample = sampleIndex // 1
      decimalOfSample = sampleIndex % 1
      thisGrainLength = 0
      
      if (input.length - sampleIndex) > grainLength
        thisGrainLength = grainLength
      else
        thisGrainLength = input.length - sampleIndex

      grainEnd = sampleIndex + thisGrainLength
      thisGrain = input.slice(sampleIndex, grainEnd)
      grains.push @shift(thisGrain, decimalOfSample)

      sampleIndex += grainRate

    grainIndex = 0
    while grainIndex < grains.length
      grains[grainIndex] = @speed grains[grainIndex], factor: factor
      grains[grainIndex] = @fadeIn(@fadeOut(grains[grainIndex]))
      grainIndex++

    sampleIndex = 0
    while sampleIndex < input.length
      output.push 0
      sampleIndex++

    intervalIndex = 0
    grainIndex = 0
    while grainIndex < grains.length
      sampleIndex = 0
      while sampleIndex < grains[grainIndex].length
        intervalIndex = grainIndex
        intervalIndex *= grainRate
        intervalIndex = intervalIndex // 1
        intervalIndex += sampleIndex
        output[intervalIndex] += grains[grainIndex][sampleIndex]
        sampleIndex++
      grainIndex++

    output



  superGrain: (input, effect) ->
    effect = effect or {}
    passes = effect.passes or 3
    grainLength = effect.grainLength or 8048
    iterations = effect.iterations or 10
    factor = effect.factor or 1
    breath = effect.breath or 0.5
    renditions = []

    iteration = 0
    while iteration < iterations
      thisGrainLength = (grainLength / iterations) 
      thisGrainLength *= iteration
      thisGrainLength += grainLength * breath
      thisGrainLength = thisGrainLength // 1

      effectOfThisIteration =
        factor:      factor
        grainLength: thisGrainLength
        passes:      passes

      renditions.push @grain(input, effectOfThisIteration)
      iteration++

    output = []
    sampleIndex = 0
    while sampleIndex < input.length
      output.push 0
      sampleIndex++

    for rendition in renditions
      sampleIndex = 0
      while sampleIndex < rendition.length
        output[sampleIndex] += rendition[sampleIndex] / iterations
        sampleIndex++

    output



  glissando: (input, effect) ->
    output = []
    factor = effect.factor or 1
    grainLength = effect.grainLength
    passes = effect.passes
    grainRate = grainLength / passes
    grains = []

    sampleIndex = 0
    while sampleIndex < input.length
      startingSample = sampleIndex // 1
      decimalOfSample = sampleIndex % 1
      thisGrainLength = 0
      
      if (input.length - sampleIndex) > grainLength
        thisGrainLength = grainLength
      else
        thisGrainLength = input.length - sampleIndex

      grainEnd = sampleIndex + thisGrainLength
      thisGrain = input.slice(sampleIndex, grainEnd)
      grains.push @shift(thisGrain, decimalOfSample)

      sampleIndex += grainRate

    factorIncrement = (factor - 1) / grains.length

    grainIndex = 0
    while grainIndex < grains.length
      thisGrainsFactor = factor: ((factorIncrement * grainIndex) + 1).toFixed(2)
      grains[grainIndex] = @speed grains[grainIndex], thisGrainsFactor
      grains[grainIndex] = @fadeIn(@fadeOut(grains[grainIndex]))
      grainIndex++

    sampleIndex = 0
    while sampleIndex < input.length
      output.push 0
      sampleIndex++

    intervalIndex = 0
    grainIndex = 0
    while grainIndex < grains.length
      sampleIndex = 0
      while sampleIndex < grains[grainIndex].length
        intervalIndex = grainIndex
        intervalIndex *= grainRate
        intervalIndex = intervalIndex // 1
        intervalIndex += sampleIndex
        output[intervalIndex] += grains[grainIndex][sampleIndex]
        sampleIndex++
      grainIndex++

    output



  lopass: (input, effect) ->
    effect = effect or {}
    depth = effect.depth or 1.5
    mix = effect.mix or 1
    wing = effect.wing or 25

    expandedInput = []
    output = []

    time = 0
    while time < wing
      expandedInput.push input[0]
      time++

    sampleIndex = 0
    while sampleIndex < input.length
      expandedInput.push input[sampleIndex]
      sampleIndex++

    time = 0
    while time < wing
      expandedInput.push input[input.length - 1]
      time++

    divisor = depth ** wing
    summation = 0
    leftWing = []

    wingIndex = 0
    while wingIndex < wing
      summation += depth ** wingIndex
      leftWing.push depth ** wingIndex
      wingIndex++

    rightWing = leftWing.reverse()

    #
    #      2 ** wing
    #         |
    #         *          ---
    #         *           |
    #         *           |
    # L. Wing * R. wing   |
    #     |   *  |        |
    #   |----|*|----|     |
    #         *           |
    #         *           |
    #        ***          | Greatest Depth
    #        ***          | 2 ** wing length
    #        ***          |
    #        ***          |
    #       *****         |
    #       *****         |
    #      *******        |
    #     *********      ---
    #  |--------------|
    #    Factor Range ( FR )

    #
    #      input = [ a, b, d, e, f, g, h, i, j, k, l, m, n, o, p ... ]
    #                |  |  |  |  |  |  |
    #                |  |  |  |  |  |  |
    #                |  |  |  |  |  |  |
    #                |  |     |  |  |  |
    #                |  |  d  |  |  |  |
    #                |  |     |  |  |  |
    #                |  |  *  |  |  |  |
    #                |  |  *  |  |  |  |
    #                |  |  *  |  |  |  |
    #                |  |  *  |  |  |  |
    #                |  |  *  |  |  |  |
    #                |     *     |  |  |
    #          ------|  b  *  e  |  |  |
    #          |  |  |     *     |  |  |
    #          |  |  |  *  *  *  |  |  |
    #          |  |     *  *  *     |  |
    #          |     a  *  *  *  f     |
    #             a     *  *  *     g
    #          a     *  *  *  *  *     h
    #                *  *  *  *  *   
    #             *  *  *  *  *  *  * 
    #          *  *  *  *  *  *  *  *  *
    # Multiply by
    #
    # FR @   [ 1, 2, 4, 8, 16,8, 4, 2, 1 ]
    #
    # Add together
    #           --|  |  |  |  |  |  |--
    #              --|  |  |  |  |--
    #                 --|  |  |--
    #                    --|--
    #                      |
    #
    # Divide      / sum(depth at wingSpot) 
    #            /  for wingSpot 
    #           /   from 0 to (wing length * 2 + 1) 
    #
    #                      |
    #                      |
    #
    #     output = [ a, b, d, e, f, g, h, i, j, k, l, m, n, o, p ... ]
    #

    factorRange = leftWing.concat [(2 ** wing)]
    factorRange = factorRange.concat rightWing 

    summation *= 2
    divisor += summation

    if depth < 2
      divisor = factorRange.length
      factorIndex = 0
      while factorIndex < factorRange.length
        factorRange[factorIndex] = 1
        factorIndex++

    sampleIndex = 0
    while sampleIndex < input.length
      value = 0
      factorIndex = 0
      while factorIndex < factorRange.length
        thisContributionToValue = factorRange[factorIndex]
        thisContributionToValue *= expandedInput[sampleIndex + factorIndex]
        value -= thisContributionToValue
        output[sampleIndex] = Math.round(value / divisor)
        factorIndex++
      sampleIndex++

    sampleIndex = 0
    while sampleIndex < input.length
      output[sampleIndex] = output[sampleIndex] * mix
      output[sampleIndex] += input[sampleIndex] * (1 - mix)
      sampleIndex++

    output



  hipass: (input, effect) ->
    input0 = input
    input1 = @invert(@lopass(input, effect))

    output = []
    whereAt = place or 0

    sampleIndex = 0
    while sampleIndex < input1.length
      output.push input1[sampleIndex]
      sampleIndex++

    if (whereAt + input0.length) > input1.length
      padding = 0
      while padding < ((whereAt + input0.length) - input1.length)
        output.push 0
        padding++

    sampleIndex = 0
    while sampleIndex < input0.length
      output[whereAt + sampleIndex] += input0[sampleIndex]
      sampleIndex++

    output
